//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "CurrentRoomManager.h"
#import "QueueSong.h"
#import "ParseUserManager.h"
@import ParseLiveQuery;

@implementation CurrentRoomManager {
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

- (void)removeAllUsers {
    if (_currentRoom) {
        [QueueSong deleteAllQueueSongsWithRoomId:_currentRoomId];
        [_currentRoom deleteEventually];
    }
}

# pragma mark - Queue

- (void)requestSongWithSpotifyId:(NSString *)spotifyId {
    if (_currentRoom) {
        QueueSong *newSong = [QueueSong new];
        newSong.roomId = _currentRoomId;
        newSong.spotifyId = spotifyId;
        [newSong saveInBackground];
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
            self->_currentRoom = (Room *)room;
            self->_currentRoomId = self->_currentRoom.objectId;
            self->_hostId = self->_currentRoom.hostId;
            [[NSNotificationCenter defaultCenter] postNotificationName:ParseRoomManagerJoinedRoomNotification object:self];
        }
    }];
}

@end
