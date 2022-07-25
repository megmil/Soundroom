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
#import "SpotifyAPIManager.h"
#import "SpotifySessionManager.h"
#import "Room.h"
#import "Invitation.h"

@implementation RoomManager {
    Room *_room;
    NSMutableArray <Song *> *_queue;
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
    
    if ([self isCurrentUserHost]) {
        [self clearAllRoomData];
        return;
    }
    
    [self clearLocalRoomData];
    
}

- (void)insertRequest:(Request *)request {
    [Song songWithRequest:request completion:^(Song *song) {
        [self insertSong:song];
        [self postUpdatedQueueNotification];
    }];
}

- (void)removeRequestWithId:(NSString *)requestId {
    NSUInteger index = [[_queue valueForKey:@"requestId"] indexOfObject:requestId];
    [_queue removeObjectAtIndex:index];
    [self postUpdatedQueueNotification];
}

- (void)incrementScoreForRequestWithId:(NSString *)requestId amount:(NSNumber *)amount {
    NSUInteger index = [[_queue valueForKey:@"requestId"] indexOfObject:requestId];
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

- (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState {
    
    // update vote state
    NSUInteger index = [[_queue valueForKey:@"requestId"] indexOfObject:requestId];
    Song *song = [_queue objectAtIndex:index];
    song.voteState = voteState;
    [_queue replaceObjectAtIndex:index withObject:song];
    
    // create/delete upvote/downvote
    [ParseObjectManager updateCurrentUserVoteForRequestWithId:requestId voteState:voteState]; // will send updated queue notification
    
}

- (void)reloadTrackData {
    
    for (Song *song in _queue) {
        
        if (song.track) {
            return;
        }
        
        [[SpotifyAPIManager shared] getTrackWithSpotifyId:song.spotifyId completion:^(Track *track, NSError *error) {
            
            song.track = track;
            
            if (song == [self->_queue lastObject]) {
                [self postUpdatedQueueNotification];
            }
            
        }];
        
    }
    
}

- (void)playTopSong {
    
    if (_queue.count) {
        
        // get and remove first song from queue
        Song *topSong = _queue.firstObject;
        [_queue removeObject:topSong];
        
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
    
    // TODO: set current track info
    
    [self loadLocalQueueDataWithCompletion:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self postUpdatedQueueNotification];
        }
    }];
    
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

- (void)clearAllRoomData {
    // delete room and attached requests, invitations, and votes
    [ParseObjectManager deleteCurrentRoomAndAttachedObjects]; // TODO: completion to make sure we don't load room that should be deleted?
    [self clearLocalRoomData];
}

# pragma mark - Queue Helpers

- (void)loadLocalQueueDataWithCompletion:(PFBooleanResultBlock)completion {
    
    [ParseQueryManager getRequestsInCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        
        if (!objects || !objects.count) {
            completion(YES, error);
            return;
        }
        
        [Song songsWithRequests:objects completion:^(NSMutableArray<Song *> *songs) {
            
            if (!songs || !songs.count) {
                self->_queue = [NSMutableArray<Song *> array];
                completion(YES, nil);
                return;
            }
            
            [Song loadVotesForQueue:songs completion:^(NSMutableArray<Song *> *result) {
                
                if (!result || !result.count) {
                    completion(YES, nil);
                    return;
                }
                
                self->_queue = result;
                [self sortQueue];
                completion(YES, nil);
                
            }];
            
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

# pragma mark - Room Data

- (NSString *)currentRoomId {
    return _room.objectId;
}

- (NSString *)currentRoomName {
    return _room.title;
}

- (NSString *)currentHostId {
    return _room.hostId;
}

- (NSMutableArray<Song *> *)queue {
    return _queue;
}

- (BOOL)isCurrentUserHost {
    
    NSString *currentUserId = [ParseUserManager currentUserId];
    
    if (self.currentHostId && currentUserId) {
        return [self.currentHostId isEqualToString:currentUserId];
    }
    
    return NO;
    
}

- (void)setCurrentTrack:(Track *)currentTrack {
    _currentTrack = currentTrack;
    if ([self isCurrentUserHost]) {
        [[SpotifySessionManager shared] playSongWithSpotifyURI:currentTrack.spotifyURI];
    }
}

# pragma mark - Helpers

- (void)postUpdatedQueueNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerUpdatedQueueNotification object:self];
}

@end
