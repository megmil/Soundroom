//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseRoomManager.h"
#import "QueueSong.h"
@import ParseLiveQuery;

@implementation ParseRoomManager {
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

- (void)requestSongWithSpotifyId:(NSString *)spotifyId completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [QueueSong requestSongWithSpotifyId:spotifyId roomId:self.currentRoomId completion:completion];
    }
}

- (void)inviteUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [_currentRoom addUniqueObject:userId forKey:@"memberIds"];
        [_currentRoom saveInBackgroundWithBlock:completion];
    }
}

- (void)removeCurrentUserWithCompletion:(PFBooleanResultBlock)completion {
    // TODO: if user is host, end the room
    PFUser *currentUser = [PFUser currentUser];
    NSString *currentUserId = currentUser.objectId;
    [self removeUserWithId:currentUserId completion:completion];
}

- (void)removeUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion {
    if (_currentRoom) {
        [_currentRoom removeObject:userId forKey:@"memberIds"];
        [_currentRoom saveInBackgroundWithBlock:completion];
    }
}

- (void)lookForCurrentRoomWithCompletion:(PFBooleanResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query whereKey:@"memberIds" equalTo:[PFUser currentUser].objectId]; // get rooms that include currentUser as a member
    [query findObjectsInBackgroundWithBlock:^(NSArray *rooms, NSError *error) {
        // TODO: error if more than one room
        if (rooms.count == 1) {
            Room *room = rooms.firstObject;
            self.currentRoomId = room.objectId;
            completion(room, error);
        } else {
            completion(nil, error);
        }
    }];
}

- (BOOL)currentRoomExists {
    return _currentRoom;
}

- (NSString *)currentRoomTitle {
    if (_currentRoom) {
        return _currentRoom.title;
    }
    return @"Room name";
}

- (void)setCurrentRoomId:(NSString *)currentRoomId {
    if (self.currentRoomId == currentRoomId) {
        return;
    }
    
    [Room getRoomWithId:currentRoomId completion:^(PFObject *room, NSError *error) {
        if (room) {
            _currentRoom = (Room *)room;
            [[NSNotificationCenter defaultCenter] postNotificationName:ParseRoomManagerJoinedRoomNotification object:self];
        }
    }];
}

- (void)resetCurrentRoomId {
    self.currentRoomId = @"";
    _currentRoom = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:ParseRoomManagerLeftRoomNotification object:self];
}

@end
