//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "RoomManager.h"
#import "QueueSong.h"
#import "ParseUserManager.h"
@import ParseLiveQuery;

@implementation RoomManager {
    Room *_currentRoom;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

# pragma mark - Fetch

- (void)fetchCurrentRoom {
    
    NSString *currentUserId = [ParseUserManager currentUserId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"userId" equalTo:currentUserId];
    [query whereKey:@"isPending" equalTo:@(NO)];
    
    // check for accepted invitation
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            // user is already in a room
            Room *room = objects.firstObject; // objects.count should always be 1
            [self joinRoom:room];
        } else {
            // user is not in a room
            [self leaveCurrentRoom];
        }
    }];
    
}

# pragma mark - Join/Leave

- (void)joinRoomWithId:(NSString * _Nonnull)currentRoomId {
    
    if (_currentRoomId == currentRoomId) {
        return;
    }
    
    [Room getRoomWithId:currentRoomId completion:^(PFObject *object, NSError *error) {
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
    
    _currentRoom = room;
    _currentRoomId = room.objectId;
    _currentRoomName = room.title;
    _currentHostId = room.hostId;
    _currentSongId = room.currentSongId;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerJoinedRoomNotification object:self];
    
}

- (void)leaveCurrentRoom {
    
    if (_currentRoom == nil) {
        return;
    }
    
    // TODO: delete invitation
    
    // TODO: delete queue
    
    _currentRoom = nil;
    _currentRoomId = nil;
    _currentRoomName = nil;
    _currentHostId = nil;
    _currentSongId = nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerLeftRoomNotification object:self];
    
}

- (void)deleteCurrentRoom {
    
    // delete room
    [Room getRoomWithId:_currentRoomId completion:^(PFObject *object, NSError *error) {
        if (object) {
            [object deleteEventually];
        }
    }];
    
    // delete all queue songs, votes, and invitations linked to room
    [self deleteAllRoomObjectsWithClassName:@"QueueSong"];
    [self deleteAllRoomObjectsWithClassName:@"Vote"];
    [self deleteAllRoomObjectsWithClassName:@"Invitation"];
    
    // clear properties
    [self leaveCurrentRoom];
    
}

# pragma mark - Helpers

- (void)deleteAllRoomObjectsWithClassName:(NSString *)className {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:@"roomId" equalTo:_currentRoomId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self deleteAllObjects:objects];
    }];
}

- (void)deleteAllObjects:(NSArray *)objects {
    for (PFObject *object in objects) {
        [object deleteEventually];
    }
}

- (BOOL)isCurrentUserHost {
    
    NSString *currentUserId = [ParseUserManager currentUserId];
    
    if (_currentHostId && currentUserId) {
        return [_currentHostId isEqualToString:currentUserId];
    }
    
    return NO;
    
}

@end
