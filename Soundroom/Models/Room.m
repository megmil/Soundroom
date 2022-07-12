//
//  Room.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Room.h"
#import "ParseUserManager.h"

@implementation Room

@dynamic roomId;
@dynamic members;
@dynamic queue;
@dynamic title;

+ (nonnull NSString *)parseClassName {
    return @"Room";
}

+ (void)createRoomWithTitle:(NSString *)title completion:(PFBooleanResultBlock _Nullable)completion {
    Room *newRoom = [Room new];
    newRoom.queue = [NSMutableArray array];
    newRoom.members = [NSMutableArray array];
    [newRoom.members addObject:[PFUser currentUser]];
    newRoom.title = title;
    
    [newRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [[ParseUserManager shared] addCurrentUserToRoomWithRoomId:newRoom.roomId completion:^(BOOL succeeded, NSError * _Nullable error) {
                // TODO: completion
            }];
        }
    }];
}

@end
