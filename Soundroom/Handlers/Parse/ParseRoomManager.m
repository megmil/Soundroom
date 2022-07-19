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
    NSMutableArray <QueueSong *> *_queue;
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
        [QueueSong deleteAllQueueSongsWithRoomId:_currentRoomId];
        [_currentRoom deleteEventually];
    }
}

# pragma mark - Queue

- (void)requestSongWithSpotifyId:(NSString *)spotifyId spotifyURI:(NSString *)spotifyURI completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [QueueSong requestSongWithSpotifyId:spotifyId spotifyURI:spotifyURI roomId:_currentRoomId completion:completion];
    }
}

- (void)refreshQueue {
    PFQuery *query = [self queueQuery];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            self->_queue = (NSMutableArray <QueueSong *> *)objects;
            [[NSNotificationCenter defaultCenter] postNotificationName:ParseRoomManagerUpdatedQueueNotification object:self];
        }
    }];
}

- (PFQuery *)queueQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query whereKey:@"roomId" equalTo:_currentRoomId];
    [query orderByDescending:@"score"];
    return query;
}

- (NSMutableArray <QueueSong *> *)queue {
    return _queue;
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
    [_queue removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:ParseRoomManagerLeftRoomNotification object:self];
}

- (void)setCurrentRoomId:(NSString *)currentRoomId {
    
    if (currentRoomId == self.currentRoomId) {
        return;
    }
    
    [Room getRoomWithId:currentRoomId completion:^(PFObject *room, NSError *error) {
        if (room) {
            self->_currentRoom = (Room *)room;
            self->_hostId = self->_currentRoom.hostId;
            self->_currentRoomId = self->_currentRoom.objectId;
            self->_queue = [NSMutableArray array];
            [[NSNotificationCenter defaultCenter] postNotificationName:ParseRoomManagerJoinedRoomNotification object:self];
        }
    }];
}

@end
