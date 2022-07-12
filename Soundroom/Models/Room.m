//
//  Room.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Room.h"

@implementation Room

@dynamic roomID;
@dynamic members;
@dynamic queue;
@dynamic playedSongs;
@dynamic title;
@dynamic coverImageData;

+ (nonnull NSString *)parseClassName {
    return @"Room";
}

@end
