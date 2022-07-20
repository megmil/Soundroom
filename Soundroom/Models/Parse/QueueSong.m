//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"

@implementation QueueSong

@dynamic objectId;
@dynamic roomId;
@dynamic spotifyId;

+ (nonnull NSString *)parseClassName {
    return @"QueueSong";
}

@end
