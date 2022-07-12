//
//  ParseRoomManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseRoomManager.h"

@implementation ParseRoomManager

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)createRoomWithTitle:(NSString *)title completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion {
    Room *newRoom = [Room new];
    newRoom.queue = [NSMutableArray array];
    newRoom.members = [NSMutableArray array];
    [newRoom.members addObject:[PFUser currentUser]];
    newRoom.title = title;
    
    // TODO: notification that current user is in room
    
    [newRoom saveInBackgroundWithBlock:completion];
}

@end
