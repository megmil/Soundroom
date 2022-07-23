//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "RoomManager.h"
#import "ParseUserManager.h"
#import "ParseObjectManager.h"
#import "ParseQueryManager.h"
#import "ParseLiveQueryManager.h"
#import "Room.h"
#import "Vote.h"
#import "Invitation.h"

@implementation RoomManager {
    
    Room *_currentRoom;
    
    NSMutableArray <QueueSong *> *_queue;
    NSMutableArray <NSNumber *> *_scores;
    
    NSMutableSet <NSString *> *_upvotedSongIds;
    NSMutableSet <NSString *> *_downvotedSongIds;
    BOOL _didLoadUserVotes;
    
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

# pragma mark - Room

- (void)fetchCurrentRoomWithCompletion:(PFBooleanResultBlock)completion {
    
    [ParseQueryManager getInvitationAcceptedByCurrentUserWithCompletion:^(PFObject *object, NSError *error) {
        if (object) {
            // user is already in a room
            completion(YES, error);
            Invitation *invitation = (Invitation *)object;
            [self joinRoomWithId:invitation.roomId];
        } else {
            // user is not in a room
            completion(NO, error);
            [self clearLocalRoomData];
        }
    }];
    
}

- (void)joinRoomWithId:(NSString *)roomId {
    
    if (_currentRoomId == roomId) {
        return;
    }
    
    [ParseQueryManager getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
        if (object) {
            Room *room = (Room *)object;
            [self joinRoom:room];
        }
    }];
    
}

- (void)joinRoom:(Room * _Nonnull)room {
    
    if (_currentRoom == room) {
        return;
    }
    
    // set local room data
    _currentRoom = room;
    _currentRoomId = room.objectId;
    _currentRoomName = room.title;
    _currentHostId = room.hostId;
    _currentSongId = room.currentSongId;
    _isInRoom = YES;
    
    // configure live subscriptions for current room data
    [[ParseLiveQueryManager shared] configureRoomLiveSubscriptions];
    
    [self setLocalQueueData];
    [self loadUserVotesWithCompletion:^(BOOL succeeded) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerJoinedRoomNotification object:self];
        }
    }];
    
}

- (void)clearRoomData {
    
    if ([self isCurrentUserHost]) {
        [self clearAllRoomData];
        return;
    }
    
    [self clearLocalRoomData];
    
}

- (void)clearLocalRoomData {
    
    if (_currentRoom == nil) {
        return;
    }
    
    // clear local room data
    _currentRoom = nil;
    _currentRoomId = nil;
    _currentRoomName = nil;
    _currentHostId = nil;
    _currentSongId = nil;
    _isInRoom = NO;
    
    // clear local queue data
    _queue = [NSMutableArray <QueueSong *> array];
    _scores = [NSMutableArray <NSNumber *> array];
    
    [self clearLocalVoteData];
    [[ParseLiveQueryManager shared] clearRoomLiveSubscriptions];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerLeftRoomNotification object:self];
    
}

- (void)clearAllRoomData {
    // delete room and attached songs, invitations, and votes
    [ParseObjectManager deleteCurrentRoomAndAttachedObjects]; // TODO: completion to make sure we don't load room that should be deleted?
    [self clearLocalRoomData];
}

# pragma mark - Queue

- (void)updateQueueSongWithId:(NSString * _Nonnull)songId {
    [self _updateQueueSongWithId:songId completion:^(BOOL succeeded) {
        if (succeeded) {
            [self postUpdatedQueueNotification];
        }
    }];
}

- (void)removeQueueSong:(QueueSong *)song {
    [self _removeQueueSong:song];
    [self postUpdatedQueueNotification];
}

- (void)insertQueueSong:(QueueSong *)song {
    [self _insertQueueSong:song completion:^(BOOL succeeded) {
        if (succeeded) {
            [self postUpdatedQueueNotification];
        }
    }];
}

- (void)_updateQueueSongWithId:(NSString *)songId completion:(void (^)(BOOL succeeded))completion {
    [ParseQueryManager getSongWithId:songId completion:^(PFObject *object, NSError *error) {
        if (object) {
            QueueSong *song = (QueueSong *)object;
            [self _removeQueueSong:song];
            [self _insertQueueSong:song completion:completion];
        }
    }];
}

- (void)_removeQueueSong:(QueueSong *)song {
    NSUInteger index = [_queue indexOfObject:song];
    if (index != NSNotFound) {
        [_queue removeObjectAtIndex:index];
        [_scores removeObjectAtIndex:index];
    }
}

- (void)_insertQueueSong:(QueueSong *)song completion:(void (^)(BOOL succeeded))completion {
    
    [self getScoreForSongWithId:song.objectId completion:^(NSNumber *score) {
        
        // get index at the earliest obj in scores array where score > obj
        NSUInteger index = [self->_scores indexOfObjectPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop) {
            return [obj compare:score] == NSOrderedAscending;
        }];
        
        // edge cases: empty arrays or score is not greater than any item in scores array
        if (index == NSNotFound) {
            [self->_queue addObject:song];
            [self->_scores addObject:score];
            completion(YES);
            return;
        }
        
        [self->_queue insertObject:song atIndex:index];
        [self->_scores insertObject:score atIndex:index];
        completion(YES);
        
    }];
    
}

- (void)setLocalQueueData {
    [ParseQueryManager getSongsInCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        if (objects) {
            self->_queue = (NSMutableArray <QueueSong *> *)objects;
            [self sortQueue];
            [self postUpdatedQueueNotification];
        }
    }];
}

- (void)sortQueue {
    
    // calculate score for each queue song
    [self fetchQueueScoresWithCompletion:^(NSMutableArray<NSNumber *> *scores) {
        
        if (!scores) {
            return;
        }
        
        // create permutation array to log order change
        NSMutableArray <NSNumber *> *permutationArray = [NSMutableArray arrayWithCapacity:scores.count];
        for (NSUInteger i = 0; i != scores.count; i++) {
            [permutationArray addObject:[NSNumber numberWithInteger:i]];
        }
        
        // sort permutation array according to scores
        [permutationArray sortWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *lhs = [scores objectAtIndex:[obj1 intValue]];
            NSNumber *rhs = [scores objectAtIndex:[obj2 intValue]];
            return [rhs compare:lhs];
        }];
        
        // use the permutation to re-order the queue and scores
        NSMutableArray <QueueSong *> *sortedQueue = [NSMutableArray arrayWithCapacity:scores.count];
        NSMutableArray <NSNumber *> *sortedScores = [NSMutableArray arrayWithCapacity:scores.count];
        [permutationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSUInteger pos = [obj intValue];
            [sortedQueue addObject:[self->_queue objectAtIndex:pos]];
            [sortedScores addObject:[scores objectAtIndex:pos]];
        }];
        
        self->_queue = sortedQueue;
        self->_scores = sortedScores;
        
    }];
    
}


# pragma mark - Votes

- (void)fetchQueueScoresWithCompletion:(void (^)(NSMutableArray <NSNumber *> *scores))completion {
    
    // TODO: pass in queue?
    
    NSMutableArray <NSNumber *> *scores = [NSMutableArray arrayWithCapacity:_queue.count];
    for (NSUInteger i = 0; i != _queue.count; i++) {
        [scores addObject:@(0)];
    }
    
    [ParseQueryManager getVotesInCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        for (Vote *vote in objects) {
            NSUInteger index = [[self->_queue valueForKey:@"objectId"] indexOfObject:vote.songId];
            if (index != NSNotFound) {
                NSNumber *currentScore = [scores objectAtIndex:index];
                NSNumber *newScore = @(currentScore.integerValue + vote.increment.integerValue);
                [scores replaceObjectAtIndex:index withObject:newScore];
            }
        }
        
        completion(scores);
        
    }];
    
}

- (void)getScoreForSongWithId:(NSString *)songId completion:(void (^)(NSNumber *result))completion {
    
    [ParseQueryManager getVotesForSongWithId:songId completion:^(NSArray *objects, NSError *error) {
        __block NSInteger score = 0;
        for (Vote *vote in objects) {
            score += vote.increment.integerValue;
        }
        completion(@(score));
    }];
    
}

- (void)getVoteStateForSongWithId:(NSString *)songId completion:(void (^)(VoteState voteState))completion {
    
    if (_didLoadUserVotes) {
        [self _getVoteStateForSongWithId:songId completion:completion];
        return;
    }
    
    [self loadUserVotesWithCompletion:^(BOOL succeeded) {
        [self _getVoteStateForSongWithId:songId completion:completion];
        return;
    }];
    
}

- (void)loadUserVotesWithCompletion:(void (^)(BOOL succeeded))completion {
    
    [self clearLocalVoteData];
    
    [ParseQueryManager getVotesByCurrentUserInCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        for (Vote *vote in objects) {
            if (vote.increment.intValue == 1) {
                [self->_upvotedSongIds addObject:vote.songId];
            } else if (vote.increment.intValue == -1) {
                [self->_downvotedSongIds addObject:vote.songId];
            }
        }
        self->_didLoadUserVotes = YES;
        completion(YES);
    }];
    
}

- (void)_getVoteStateForSongWithId:(NSString *)songId completion:(void (^)(VoteState voteState))completion {
    
    if ([self didUpvoteSongWithId:songId]) {
        completion(Upvoted);
        return;
    }
    
    if ([self didDownvoteSongWithId:songId]) {
        completion(Downvoted);
        return;
    }
    
    completion(NotVoted);
    
}

- (BOOL)didUpvoteSongWithId:(NSString *)songId {
    return [_upvotedSongIds containsObject:songId];
}

- (BOOL)didDownvoteSongWithId:(NSString *)songId {
    return [_downvotedSongIds containsObject:songId];
}

- (void)clearLocalVoteData {
    _upvotedSongIds = [NSMutableSet<NSString *> set];
    _downvotedSongIds = [NSMutableSet<NSString *> set];
    _didLoadUserVotes = NO;
}

# pragma mark - Playback

- (void)playTopSong {
    if (_queue.count) {
        // get and remove first song from queue
        QueueSong *topSong = _queue.firstObject;
        [self _removeQueueSong:topSong];
        
        // save current song to room
        [ParseObjectManager updateCurrentRoomWithCurrentSongId:topSong.objectId];
        
    }
}

# pragma mark - Helpers

- (BOOL)isCurrentUserHost {
    
    NSString *currentUserId = [ParseUserManager currentUserId];
    
    if (_currentHostId && currentUserId) {
        return [_currentHostId isEqualToString:currentUserId];
    }
    
    return NO;
    
}

- (void)postUpdatedQueueNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerUpdatedQueueNotification object:self];
}

@end
