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
#import "SpotifyAPIManager.h"
#import "SpotifySessionManager.h"
#import "Room.h"
#import "Invitation.h"

NSString *const RoomManagerJoinedRoomNotification = @"RoomManagerJoinedRoomNotification";

@implementation RoomManager {
    Room *_room;
    NSMutableArray <Song *> *_queue;
    Track *_currentTrack;
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
                [self.delegate insertCellAtIndex:index];
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
    [self.delegate deleteCellAtIndex:index];
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
            [self.delegate moveCellAtIndex:oldIndex toIndex:newIndex];
        }
    }];

}

- (void)setCurrentTrackWithSpotifyId:(NSString *)spotifyId {
    
    if ([spotifyId isEqualToString:@""]) {
        self.currentTrack = nil;
        [self.delegate didUpdateCurrentTrack];
        return;
    }
    
    [[SpotifyAPIManager shared] getTrackWithSpotifyId:spotifyId completion:^(Track *track, NSError *error) {
        if (track) {
            self.currentTrack = track;
            [self.delegate didUpdateCurrentTrack];
        }
    }];
    
}

# pragma mark - Public: Room Tab

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

- (void)reloadTrackDataWithCompletion:(PFBooleanResultBlock)completion {
    
    if (!_room) {
        completion(NO, nil);
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
        
        [[SpotifyAPIManager shared] getTrackWithSpotifyId:song.spotifyId completion:^(Track *track, NSError *error) {
            
            song.track = track;
            
            if (--remainingTracks == 0) {
                [self reloadCurrentTrackDataWithCompletion:completion];
            }
            
        }];
        
    }
    
}

- (void)reloadCurrentTrackDataWithCompletion:(PFBooleanResultBlock)completion {
    
    if (!_room) {
        completion(NO, nil);
        return;
    }
    
    if (_currentTrack) {
        completion(YES, nil);
        return;
    }
    
    [[SpotifyAPIManager shared] getTrackWithSpotifyId:_room.currentSongSpotifyId completion:^(Track *track, NSError *error) {
        self.currentTrack = track;
        completion(YES, nil);
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

- (void)togglePlayback {
    
    if (_currentTrack) {
        // stop current song
        [ParseObjectManager updateCurrentRoomWithSongWithSpotifyId:@""];
        return;
    }
    
    [self playTopSong];
    
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
        [self.delegate didRefreshQueue];
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
    _queue = [NSMutableArray <Song *> array];
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
    
    __block NSMutableArray <Song *> *result = [NSMutableArray <Song *> array];
    
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
                
                NSUInteger index = [[result valueForKey:requestIdKey] indexOfObject:upvote.requestId];
                
                if (index != NSNotFound) {
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
                
                NSUInteger index = [[result valueForKey:requestIdKey] indexOfObject:downvote.requestId];
                
                if (index != NSNotFound) {
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

- (void)playTopSong {
    
    if (_queue.count) {
        
        // get and remove first song from queue
        Song *topSong = _queue.firstObject;
        [ParseObjectManager deleteRequestWithId:topSong.requestId];
        
        // save current song to room
        [ParseObjectManager updateCurrentRoomWithSongWithSpotifyId:topSong.spotifyId];
        
    }
    
}

- (void)loadCurrentTrack {
    if (_room.currentSongSpotifyId) {
        [[SpotifyAPIManager shared] getTrackWithSpotifyId:_room.currentSongSpotifyId completion:^(Track *track, NSError *error) {
            self.currentTrack = track;
        }];
    }
}

- (void)setCurrentTrack:(Track *)currentTrack {
    
    _currentTrack = currentTrack;
    
    if (!currentTrack) {
        [[SpotifySessionManager shared] pausePlayback];
        return;
    }
    
    if ([self isCurrentUserHost] || _room.listeningMode == RemoteMode) {
        [[SpotifySessionManager shared] playSongWithSpotifyURI:currentTrack.spotifyURI];
    }
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

- (Track *)currentTrack {
    return _currentTrack;
}

- (BOOL)isCurrentUserHost {
    NSString *currentUserId = [ParseUserManager currentUserId];
    if (_room.hostId && currentUserId && currentUserId.length != 0) {
        return [_room.hostId isEqualToString:currentUserId];
    }
    return NO;
}

@end
