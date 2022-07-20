//
//  Room.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Room.h"
#import "ParseUserManager.h"
#import "RoomManager.h"

@implementation Room

@dynamic roomId;
@dynamic title;
@dynamic hostId;
@dynamic currentSongId;

+ (nonnull NSString *)parseClassName {
    return @"Room";
}

+ (void)createRoomWithTitle:(NSString *)title completion:(PFBooleanResultBlock)completion {
    Room *newRoom = [Room new];
    newRoom.title = title;
    newRoom.hostId = [ParseUserManager currentUserId];
    [newRoom saveInBackgroundWithBlock:completion];
}

+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query getObjectInBackgroundWithId:roomId block:completion];
}

+ (void)getCurrentRoomWithCompletion:(PFBooleanResultBlock)completion {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query whereKey:@"memberIds" equalTo:[ParseUserManager currentUserId]]; // rooms that include currentUser as a member
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *rooms, NSError *error) {
        if (rooms.count == 1) {
            Room *room = rooms.firstObject;
            [[CurrentRoomManager shared] setCurrentRoomId:room.objectId];
            completion(room, error);
        } else {
            completion(nil, error);
        }
    }];
}

@end
