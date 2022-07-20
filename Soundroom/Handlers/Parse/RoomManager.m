//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "RoomManager.h"
#import "QueueSong.h"
#import "ParseUserManager.h"
#import "InvitationManager.h"
#import "QueryManager.h"
#import "Invitation.h"
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

- (void)updateRoomWithCurrentSongId:(NSString *)currentSongId {
    [_currentRoom setValue:currentSongId forKey:@"currentSongId"];
    [_currentRoom saveInBackground];
}

+ (void)createRoomWithTitle:(NSString *)title {
    // create room
    Room *newRoom = [Room new];
    newRoom.title = title;
    newRoom.hostId = [ParseUserManager currentUserId];
    [newRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // create accepted invitation for host
            [InvitationManager registerHostForRoomWithId:newRoom.objectId];
        }
    }];
}

# pragma mark - Fetch

- (void)fetchCurrentRoom {
    
    PFQuery *query = [[QueryManager shared] queryForAcceptedInvitations];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && objects.count) {
            // user is already in a room
            Invitation *invitation = objects.firstObject; // objects.count should always be 1
            [self joinRoomWithId:invitation.roomId];
        } else {
            // user is not in a room
            [self leaveCurrentRoom];
        }
    }];
    
}

# pragma mark - Join/Leave

- (void)joinRoomWithId:(NSString * _Nonnull)roomId {
    
    if (_currentRoomId == roomId) {
        return;
    }
    
    Room *room = [PFQuery getObjectOfClass:@"Room" objectId:roomId];
    if (room) {
        [self joinRoom:room];
    }
    
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
    _isInRoom = YES;
    
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
    _isInRoom = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerLeftRoomNotification object:self];
    
}

- (void)deleteCurrentRoom {
    
    // delete room
    if (_currentRoom) {
        [_currentRoom deleteEventually];
    }
    
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
