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

- (BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[QueueSong class]]) {
        QueueSong *song = (QueueSong *)object;
        return [self.objectId isEqualToString:song.objectId];
    }
    
    return NO;
}

@end
