//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseRoomManager.h"
#import "QueueSong.h"
#import "ParseUserManager.h"
@import ParseLiveQuery;

@implementation ParseRoomManager {
    Room *_currentRoom;
    NSString *_hostId;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

#pragma mark - Invitees and Members

- (void)inviteUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [_currentRoom addUniqueObject:userId forKey:@"invitedIds"];
        [_currentRoom saveInBackgroundWithBlock:completion];
    }
}

- (void)addUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [_currentRoom addUniqueObject:userId forKey:@"memberIds"];
        [_currentRoom saveInBackgroundWithBlock:completion];
    }
}

- (void)removeUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [_currentRoom removeObject:userId forKey:@"invitedIds"];
        [_currentRoom removeObject:userId forKey:@"memberIds"];
        [_currentRoom saveInBackgroundWithBlock:completion];
    }
}

- (void)removeAllUsersWithCompletion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [_currentRoom removeObjectForKey:@"invitedIds"];
        [_currentRoom removeObjectForKey:@"memberIds"];
        [_currentRoom saveInBackgroundWithBlock:completion];
    }
}

# pragma mark - Queue

// TODO: match others
- (void)requestSongWithSpotifyId:(NSString *)spotifyId completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [QueueSong requestSongWithSpotifyId:spotifyId roomId:self.currentRoomId completion:completion];
    }
}

# pragma mark - Room Data

- (NSString *)currentRoomTitle {
    if (_currentRoom) {
        return _currentRoom.title;
    }
    return nil;
}

- (NSString *)currentHostId {
    if (_currentRoom) {
        return _currentRoom.hostId;
    }
    return nil;
}

- (void)reset {
    _currentRoomId = nil;
    _currentRoom = nil;
    _hostId = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:ParseRoomManagerLeftRoomNotification object:self];
}

- (void)setCurrentRoomId:(NSString *)currentRoomId {
    
    if (currentRoomId == self.currentRoomId) {
        return;
    }
    
    [Room getRoomWithId:currentRoomId completion:^(PFObject *room, NSError *error) {
        if (room) {
            _currentRoom = (Room *)room;
            _hostId = _currentRoom.hostId;
            [[NSNotificationCenter defaultCenter] postNotificationName:ParseRoomManagerJoinedRoomNotification object:self];
        }
    }];
}

@end
