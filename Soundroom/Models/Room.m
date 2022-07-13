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
@dynamic memberIds;
@dynamic queue;
@dynamic title;

+ (nonnull NSString *)parseClassName {
    return @"Room";
}

@end
