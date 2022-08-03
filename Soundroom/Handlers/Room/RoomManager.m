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
#import "ParseConstants.h"
#import "ParseLiveQueryManager.h"
#import "MusicAPIManager.h"
#import "MusicPlayerManager.h"
#import "Room.h"
#import "Request.h"
#import "Song.h"
#import "Upvote.h"
#import "Downvote.h"
#import "Track.h"
#import "Invitation.h"

NSString *const RoomManagerJoinedRoomNotification = @"RoomManagerJoinedRoomNotification";

@implementation RoomManager {
    Room *_room;
    Track *_currentTrack;
    NSMutableArray <Song *> *_queue;
    NSMutableSet <NSString *> *_upvoteIds;
    NSMutableSet <NSString *> *_downvoteIds;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

# pragma mark - Public: Live Query

- (void)joinRoomWithId:(NSString *)roomId {
    
    if (self.currentRoomId == roomId) {
        return;
    }
    
    [ParseQueryManager getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
        Room *room = (Room *)object;
        [self joinRoom:room];
    }];
    
}

- (void)clearRoomData {
    
    if (!_room) {
        return;
    }
    
    if ([self isCurrentUserHost]) {
        [self clearAllRoomData];
        return;
    }
    
    [self clearUserRoomData];
    
}

- (void)insertRequest:(Request *)request {
    [Song songWithRequest:request completion:^(Song *song) {
        [self insertSong:song completion:^(NSUInteger index) {
            if (index != NSNotFound) {
                [self.delegate didInsertSongAtIndex:index];
            }
        }];
    }];
}

- (void)removeRequestWithId:(NSString *)requestId {
    
    NSUInteger index = [[_queue valueForKey:requestIdKey] indexOfObject:requestId];
    if (index == NSNotFound) {
        return;
    }
    
    [_queue removeObjectAtIndex:index];
    [self.delegate didDeleteSongAtIndex:index];
    
}

- (void)addUpvote:(Upvote *)upvote {
    
    BOOL isDuplicate = [_upvoteIds containsObject:upvote.objectId];
    if (isDuplicate) {
        return;
    }
    
    [_upvoteIds addObject:upvote.objectId];
    [self incrementScoreForRequestWithId:upvote.requestId amount:@(1)];
    
}

- (void)deleteUpvote:(Upvote *)upvote {
    
    if (![_upvoteIds containsObject:upvote.objectId]) {
        return;
    }
    
    [_upvoteIds removeObject:upvote.objectId];
    [self incrementScoreForRequestWithId:upvote.requestId amount:@(-1)];
    
}

- (void)addDownvote:(Downvote *)downvote {
    
    BOOL isDuplicate = [_downvoteIds containsObject:downvote.objectId];
    if (isDuplicate) {
        return;
    }
    
    [_downvoteIds addObject:downvote.objectId];
    [self incrementScoreForRequestWithId:downvote.requestId amount:@(-1)];
    
}

- (void)deleteDownvote:(Downvote *)downvote {
    
    if (![_downvoteIds containsObject:downvote.objectId]) {
        return;
    }
    
    [_downvoteIds removeObject:downvote.objectId];
    [self incrementScoreForRequestWithId:downvote.requestId amount:@(1)];
    
}

- (void)incrementScoreForRequestWithId:(NSString *)requestId amount:(NSNumber *)amount {
    
    NSUInteger oldIndex = [[_queue valueForKey:requestIdKey] indexOfObject:requestId];
    if (oldIndex == NSNotFound) {
        return;
    }
    
    Song *song = [_queue objectAtIndex:oldIndex];
    song.score = @(song.score.integerValue + amount.integerValue);
    
    [_queue removeObjectAtIndex:oldIndex];
    [self insertSong:song completion:^(NSUInteger newIndex) {
        if (newIndex != NSNotFound) {
            [self.delegate didMoveSongAtIndex:oldIndex toIndex:newIndex];
        }
    }];
    
}

- (void)updateCurrentTrackWithISRC:(NSString *)isrc {
    
    if (!isrc || [isrc isEqualToString:@""]) {
        self.currentTrack = nil;
        return;
    }
    
    [[MusicAPIManager shared] getTrackWithISRC:isrc completion:^(Track *track, NSError *error) {
        if (track) {
            self.currentTrack = track;
        }
    }];
    
}

# pragma mark - Public: Room Tab

- (void)fetchCurrentRoomWithCompletion:(void (^)(BOOL isInRoom))completion {
    
    [ParseQueryManager getInvitationAcceptedByCurrentUserWithCompletion:^(PFObject *object, NSError *error) {
        if (object) {
            // user is already in a room
            completion(YES);
            Invitation *invitation = (Invitation *)object;
            [self joinRoomWithId:invitation.roomId];
        } else {
            // user is not in a room
            completion(NO);
            [self clearLocalRoomData];
        }
    }];
    
}

- (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState {
    
    // update vote state
    NSUInteger index = [[_queue valueForKey:requestIdKey] indexOfObject:requestId];
    Song *song = [_queue objectAtIndex:index];
    song.voteState = voteState;
    
    // create/delete upvote/downvote
    [ParseObjectManager updateCurrentUserVoteForRequestWithId:requestId voteState:voteState];
    
}

- (void)reloadTrackDataWithCompletion:(void (^)(void))completion {
    
    if (!_room) {
        return;
    }
    
    __block NSUInteger remainingTracks = _queue.count;
    
    if (remainingTracks == 0) {
        [self reloadCurrentTrackDataWithCompletion:completion];
        return;
    }
    
    for (Song *song in _queue) {
        
        if (song.track) {
            continue;
        }
        
        [[MusicAPIManager shared] getTrackWithISRC:song.isrc completion:^(Track *track, NSError *error) {
            
            song.track = track;
            
            if (--remainingTracks == 0) {
                [self reloadCurrentTrackDataWithCompletion:completion];
                return;
            }
            
        }];
        
    }
    
}

- (void)reloadCurrentTrackDataWithCompletion:(void (^)(void))completion {
    
    if (!_room) {
        return;
    }
    
    if (_currentTrack) {
        completion();
        return;
    }
    
    NSString *isrc = _room.currentISRC;
    [[MusicAPIManager shared] getTrackWithISRC:isrc completion:^(Track *track, NSError *error) {
        self.currentTrack = track;
        completion();
    }];
    
}

# pragma mark - Music Player

- (void)playTopSong {
    
    if (!_queue.count) {
        [self stopPlayback];
        return;
    }
    
    // tell session manager that song is changing
    [MusicPlayerManager shared].isSwitchingSong = YES;
    
    // get and remove first song from queue
    Song *topSong = _queue.firstObject;
    [ParseObjectManager deleteRequestWithId:topSong.requestId];
    
    // save current song to room
    [ParseObjectManager updateCurrentRoomWithISRC:topSong.isrc];
    
}

- (void)stopPlayback {
    [ParseObjectManager updateCurrentRoomWithISRC:@""];
    [self.delegate setPlayState:Paused];
}

- (void)updatePlayerWithPlayState:(PlayState)playState {
    [self.delegate setPlayState:playState];
}

# pragma mark - Room Helpers

- (void)joinRoom:(Room *)room {
    
    if (_room == room || !room) {
        return;
    }
    
    _room = room;
    [[ParseLiveQueryManager shared] configureRoomLiveSubscriptions];
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerJoinedRoomNotification object:self];
    
    [self loadCurrentTrack];
    [self loadLocalQueueDataWithCompletion:^{
        [self.delegate didLoadQueue];
    }];
    
}

- (void)clearUserRoomData {
    [ParseObjectManager deleteInvitationsAcceptedByCurrentUser];
    [self clearLocalRoomData];
}

- (void)clearAllRoomData {
    // delete room and attached requests, invitations, and votes
    [ParseObjectManager deleteCurrentRoomAndAttachedObjects]; // TODO: completion to make sure we don't load room that should be deleted?
    [self clearLocalRoomData];
}

- (void)clearLocalRoomData {
    
    if (_room == nil) {
        return;
    }
    
    // clear local room data
    _room = nil;
    _queue = [NSMutableArray <Song *> new];
    _upvoteIds = [NSMutableSet <NSString *> new];
    _downvoteIds = [NSMutableSet <NSString *> new];
    _currentTrack = nil;
    
    [[ParseLiveQueryManager shared] clearRoomLiveSubscriptions];
    
    [self.delegate didLeaveRoom];
    
}

# pragma mark - Queue Helpers

- (void)loadLocalQueueDataWithCompletion:(void (^)(void))completion {
    
    _queue = [NSMutableArray<Song *> array];
    
    [ParseQueryManager getRequestsInCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        
        if (!objects || !objects.count) {
            completion();
            return;
        }
        
        [Song songsWithRequests:objects completion:^(NSArray <Song *> *songs) {
            
            if (!songs || !songs.count) {
                completion();
                return;
            }
            
            self->_queue = (NSMutableArray <Song *> *)songs;
            
            [self loadLocalVoteDataWithCompletion:^(NSArray <Song *> *result) {
                
                if (!result || self->_queue.count != result.count) {
                    completion();
                    return;
                }
                
                self->_queue = (NSMutableArray <Song *> *)result;
                [self sortQueue];
                completion();
                
            }];
            
        }];
        
    }];
    
}

- (void)loadLocalVoteDataWithCompletion:(void (^)(NSArray <Song *> *result))completion {
    
    __block NSMutableArray <Song *> *result = [NSMutableArray <Song *> new];
    _upvoteIds = [NSMutableSet <NSString *> new];
    _downvoteIds = [NSMutableSet <NSString *> new];
    
    if (!_queue || !_queue.count) {
        completion(result);
        return;
    }
    
    result = _queue;
    NSString *currentUserId = [ParseUserManager currentUserId];
    
    [ParseQueryManager getUpvotesInCurrentRoomWithCompletion:^(NSArray *upvotes, NSError *error) {
        
        [ParseQueryManager getDownvotesInCurrentRoomWithCompletion:^(NSArray *downvotes, NSError *error) {
            
            NSUInteger remainingVotes = upvotes.count + downvotes.count;
            
            if (remainingVotes == 0) {
                completion(result);
                return;
            }
            
            for (Upvote *upvote in upvotes) {
                
                BOOL isDuplicate = [self->_upvoteIds containsObject:upvote.objectId];
                NSUInteger index = [[result valueForKey:requestIdKey] indexOfObject:upvote.requestId];
                
                if (index != NSNotFound && !isDuplicate) {
                    
                    [self->_upvoteIds addObject:upvote.objectId];
                    
                    Song *song = result[index];
                    result[index].score = @(song.score.integerValue + 1);
                    if ([upvote.userId isEqualToString:currentUserId]) {
                        song.voteState = Upvoted;
                    }
                    
                }
                
                if (--remainingVotes == 0) {
                    completion(result);
                }
                
            }
            
            for (Downvote *downvote in downvotes) {
                
                BOOL isDuplicate = [self->_downvoteIds containsObject:downvote.objectId];
                NSUInteger index = [[result valueForKey:requestIdKey] indexOfObject:downvote.requestId];
                
                if (index != NSNotFound && !isDuplicate) {
                    
                    [self->_downvoteIds addObject:downvote.objectId];
                    
                    Song *song = result[index];
                    result[index].score = @(song.score.integerValue - 1);
                    if ([downvote.userId isEqualToString:currentUserId]) {
                        song.voteState = Downvoted;
                    }
                    
                }
                
                if (--remainingVotes == 0) {
                    completion(result);
                }
                
            }
            
        }];
        
    }];
    
}

- (void)insertSong:(Song *)song completion:(void (^)(NSUInteger index))completion {
    
    // get index at the earliest obj in the queue where song.score > obj.score
    NSUInteger index = [self->_queue indexOfObjectPassingTest:^BOOL(Song *obj, NSUInteger idx, BOOL *stop) {
        return [obj.score compare:song.score] == NSOrderedAscending;
    }];
    
    // edge cases: empty arrays or score is not greater than any item in scores array
    if (index == NSNotFound) {
        [self->_queue addObject:song];
        completion(self->_queue.count - 1);
        return;
    }
    
    [self->_queue insertObject:song atIndex:index];
    completion(index);
    
}

- (void)sortQueue {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];
    [_queue sortUsingDescriptors:@[sortDescriptor]];
}

# pragma mark - Playback Helpers

- (void)loadCurrentTrack {
    if (_room.currentISRC) {
        [[MusicAPIManager shared] getTrackWithISRC:_room.currentISRC completion:^(Track *track, NSError *error) {
            self.currentTrack = track;
        }];
    }
}

- (void)setCurrentTrack:(Track *)currentTrack {
    
    _currentTrack = currentTrack;
    
    if (!currentTrack) {
        [[MusicPlayerManager shared] pausePlayback];
        return;
    }
    
    if ([self isCurrentUserHost] || _room.listeningMode == RemoteMode) {
        [[MusicPlayerManager shared] playTrackWithStreamingId:currentTrack.streamingId];
        [MusicPlayerManager shared].isSwitchingSong = NO; // TODO: switch before here if something fails
    }
    
    [self.delegate didUpdateCurrentTrack];
    
}


# pragma mark - Room Data

- (NSString *)currentRoomId {
    return _room.objectId;
}

- (NSString *)currentRoomName {
    return _room.title;
}

- (NSMutableArray<Song *> *)queue {
    return _queue;
}

// TODO: remove?
- (Track *)currentTrack {
    return _currentTrack;
}

- (NSString *)currentTrackStreamingId {
    return _currentTrack.streamingId;
}

- (BOOL)isCurrentUserHost {
    NSString *currentUserId = [ParseUserManager currentUserId];
    if (_room.hostId && currentUserId && currentUserId.length != 0) {
        return [_room.hostId isEqualToString:currentUserId];
    }
    return NO;
}

@end
