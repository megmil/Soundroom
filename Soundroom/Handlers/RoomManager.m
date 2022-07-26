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
NSString *const RoomManagerLeftRoomNotification = @"RoomManagerLeftRoomNotification";
NSString *const RoomManagerUpdatedQueueNotification = @"RoomManagerUpdatedQueueNotification";

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
        [self insertSong:song];
        [self postUpdatedQueueNotification];
    }];
}

- (void)removeRequestWithId:(NSString *)requestId {
    NSUInteger index = [[_queue valueForKey:requestIdKey] indexOfObject:requestId];
    if (index == NSNotFound) {
        return;
    }
    [_queue removeObjectAtIndex:index];
    [self postUpdatedQueueNotification];
}

- (void)incrementScoreForRequestWithId:(NSString *)requestId amount:(NSNumber *)amount {
    NSUInteger index = [[_queue valueForKey:requestIdKey] indexOfObject:requestId];
    if (index == NSNotFound) {
        return;
    }
    Song *song = [_queue objectAtIndex:index];
    song.score = @(song.score.integerValue + amount.integerValue);
    [_queue removeObjectAtIndex:index];
    [self insertSong:song];
    [self postUpdatedQueueNotification];
}

- (void)setCurrentTrackWithSpotifyId:(NSString *)spotifyId {
    [[SpotifyAPIManager shared] getTrackWithSpotifyId:spotifyId completion:^(Track *track, NSError *error) {
        if (track) {
            self.currentTrack = track;
            [self postUpdatedQueueNotification];
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

- (void)playTopSong {
    
    if (_queue.count) {
        
        // get and remove first song from queue
        Song *topSong = _queue.firstObject;
        [ParseObjectManager deleteRequestWithId:topSong.requestId];
        
        // save current song to room
        [ParseObjectManager updateCurrentRoomWithSongWithSpotifyId:topSong.spotifyId];
        
    }
    
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
    [self loadLocalQueueDataWithCompletion:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self postUpdatedQueueNotification];
        }
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerLeftRoomNotification object:self];
    
}

# pragma mark - Queue Helpers

- (void)loadLocalQueueDataWithCompletion:(PFBooleanResultBlock)completion {
    
    _queue = [NSMutableArray<Song *> array];
    
    [ParseQueryManager getRequestsInCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        
        if (!objects || !objects.count) {
            completion(YES, error);
            return;
        }
        
        [Song songsWithRequests:objects completion:^(NSMutableArray<Song *> *songs) {
            
            if (!songs || !songs.count) {
                completion(YES, nil);
                return;
            }
            
            self->_queue = songs;
            [self loadLocalVoteDataWithCompletion:^(NSMutableArray<Song *> *result) {
                
                if (!result || self->_queue.count != result.count) {
                    return;
                }
                
                self->_queue = songs;
                [self sortQueue];
                completion(YES, nil);
                
            }];
            
        }];
        
    }];
    
}

- (void)loadLocalVoteDataWithCompletion:(void (^)(NSMutableArray <Song *> *result))completion {
    
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
                        song.voteState = Upvoted;
                    }
                }
                
                if (--remainingVotes == 0) {
                    completion(result);
                }
                
            }
            
        }];
        
    }];
    
}

- (void)insertSong:(Song *)song {
    
    // get index at the earliest obj in the queue where song.score > obj.score
    NSUInteger index = [self->_queue indexOfObjectPassingTest:^BOOL(Song *obj, NSUInteger idx, BOOL *stop) {
        return [obj.score compare:song.score] == NSOrderedAscending;
    }];
    
    // edge cases: empty arrays or score is not greater than any item in scores array
    if (index == NSNotFound) {
        [self->_queue addObject:song];
        return;
    }
    
    [self->_queue insertObject:song atIndex:index];
    
}

- (void)sortQueue {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO];
    [_queue sortUsingDescriptors:@[sortDescriptor]];
}

- (void)postUpdatedQueueNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerUpdatedQueueNotification object:self];
}

# pragma mark - Playback Helpers

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
        return;
    }
    
    if ([self isCurrentUserHost]) {
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
