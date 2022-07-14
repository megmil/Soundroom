//
//  Room.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Room.h"

@implementation Room

@dynamic roomId;
@dynamic title;
@dynamic memberIds;
@dynamic queue;

+ (nonnull NSString *)parseClassName {
    return @"Room";
}

+ (void)createRoomWithTitle:(NSString *)title completion:(PFBooleanResultBlock)completion {
    Room *newRoom = [Room new];
    newRoom.title = title;
    newRoom.memberIds = [NSSet setWithObject:[PFUser currentUser].objectId];
    [newRoom saveInBackgroundWithBlock:completion];
}

+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query getObjectInBackgroundWithId:roomId block:completion];
}

@end
