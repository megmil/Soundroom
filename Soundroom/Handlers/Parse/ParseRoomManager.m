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

- (void)setCurrentRoomId:(NSString *)currentRoomId {
    if (currentRoomId) {
        [Room getRoomWithId:currentRoomId completion:^(PFObject *room, NSError *error) {
            if (room) {
                self.currentRoomId = currentRoomId;
                _currentRoom = (Room *)room;
            }
        }];
    }
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

- (void)lookForCurrentRoom {
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query whereKey:@"memberIds" equalTo:[PFUser currentUser].objectId]; // get rooms that include currentUser as a member
    [query findObjectsInBackgroundWithBlock:^(NSArray *rooms, NSError *error) {
        // TODO: error if more than one room
        if (rooms.count == 1) {
            Room *room = rooms.firstObject;
            self.currentRoomId = room.objectId;
        }
    }];
}

- (BOOL)currentRoomExists {
    return _currentRoom;
}

@end
