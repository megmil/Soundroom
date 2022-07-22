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
@dynamic hostId;
@dynamic currentSongId;

+ (nonnull NSString *)parseClassName {
    return @"Room";
}

@end
