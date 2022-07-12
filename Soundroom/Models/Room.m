//
//  Room.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Room.h"
#import "ParseRoomManager.h"

@implementation Room

@dynamic roomId;
@dynamic members;
@dynamic queue;
@dynamic title;

+ (nonnull NSString *)parseClassName {
    return @"Room";
}

+ (void)createRoomWithTitle:(NSString *)title completion:(void(^)(BOOL succeeded, NSError * _Nullable error))completion {
    [[ParseRoomManager shared] createRoomWithTitle:title completion:completion];
}

@end
