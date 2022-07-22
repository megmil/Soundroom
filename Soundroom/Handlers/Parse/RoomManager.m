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
#import "QueueManager.h"
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
    
    [QueryManager getInvitationAcceptedByCurrentUserWithCompletion:^(PFObject *object, NSError *error) {
        if (object) {
            // user is already in a room
            Invitation *invitation = (Invitation *)object;
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
    
    [QueryManager getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
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
    _isInRoom = YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerJoinedRoomNotification object:self];
    
}

- (void)_leaveCurrentRoom {
    
    if (_currentRoom == nil) {
        return;
    }
    
    [InvitationManager deleteAcceptedInvitations];
    [[QueueManager shared] resetLocalQueue];
    
    _currentRoom = nil;
    _currentRoomId = nil;
    _currentRoomName = nil;
    _currentHostId = nil;
    _currentSongId = nil;
    _isInRoom = NO;
    
}

- (void)leaveCurrentRoom {
    [self _leaveCurrentRoom];
    [[NSNotificationCenter defaultCenter] postNotificationName:RoomManagerLeftRoomNotification object:self];
}

- (void)deleteCurrentRoom {
    
    // delete room
    if (_currentRoom) {
        [_currentRoom deleteInBackground];
    }
    
    // delete all queue songs, votes, and invitations linked to room
    [self deleteAllRoomObjectsWithClassName:@"QueueSong"];
    
    // clear properties
    [self _leaveCurrentRoom];
    
}

# pragma mark - Helpers

- (BOOL)isCurrentUserHost {
    
    NSString *currentUserId = [ParseUserManager currentUserId];
    
    if (_currentHostId && currentUserId) {
        return [_currentHostId isEqualToString:currentUserId];
    }
    
    return NO;
    
}

@end
