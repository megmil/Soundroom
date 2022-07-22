//
//  VoteManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import "VoteManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "QueryManager.h"
#import "Vote.h"

@implementation VoteManager {
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

+ (void)incrementSong:(QueueSong *)song byAmount:(NSNumber *)amount {
    [self incrementSongWithId:song.objectId byAmount:amount];
}

+ (void)incrementSongWithId:(NSString *)songId byAmount:(NSNumber *)amount {
    
    // check for duplicate
    [self getVotesForSongWithId:songId completion:^(PFObject *object, NSError *error) {
        if (object) {
            // update duplicate vote
            Vote *vote = (Vote *)object;
            vote.increment = amount;
            [vote saveInBackground];
        } else {
            // create new vote
            Vote *newVote = [Vote new];
            newVote.songId = songId;
            newVote.userId = [ParseUserManager currentUserId];
            newVote.roomId = [[RoomManager shared] currentRoomId];
            newVote.increment = amount;
            [newVote saveInBackground];
        }
    }];
    
}

+ (void)getVotesForSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion {
    
    PFQuery *query = [SNDParseManager queryForUserVotesWithSongId:songId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            // this song has already been voted on (should only be one object)
            completion(objects.firstObject, nil);
        } else {
            // this song has not been voted on
            completion(nil, error);
        }
    }];
    
}

+ (void)loadScoresForQueue:(NSMutableArray <QueueSong *> *)queue completion:(void (^)(NSMutableArray <NSNumber *> *scores))completion {
    
    NSMutableArray <NSNumber *> *scores = [NSMutableArray arrayWithCapacity:queue.count];
    for (NSUInteger i = 0; i != queue.count; i++) {
        [scores addObject:@(0)];
    }
    
    [QueryManager getVotesInCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        for (Vote *vote in objects) {
            NSUInteger index = [[queue valueForKey:@"objectId"] indexOfObject:vote.songId];
            if (index != NSNotFound) {
                NSNumber *currentScore = [scores objectAtIndex:index];
                NSNumber *newScore = @(currentScore.integerValue + vote.increment.integerValue);
                [scores replaceObjectAtIndex:index withObject:newScore];
            }
        }
        completion(scores);
    }];
}

+ (void)scoreForSongWithId:(NSString *)songId completion:(void (^)(NSNumber *result))completion {
    
    PFQuery *query = [SNDParseManager queryForAllVotesWithSongId:songId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        __block NSInteger score = 0;
        for (Vote *vote in objects) {
            score += vote.increment.integerValue;
        }
        completion(@(score));
    }];
}

- (void)resetLocalVotes {
    _upvotedSongIds = [NSMutableSet<NSString *> set];
    _downvotedSongIds = [NSMutableSet<NSString *> set];
    _didLoadUserVotes = NO;
}

- (void)loadUserVotesWithCompletion:(void (^)(BOOL succeeded))completion {
    
    [self resetLocalVotes];
    
    if ([[RoomManager shared] isInRoom]) {
        PFQuery *query = [[SNDParseManager shared] queryForCurrentUserVotes];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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

@end
