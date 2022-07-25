//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Request.h"

@implementation Request

@dynamic objectId;
@dynamic roomId;
@dynamic spotifyId;

+ (nonnull NSString *)parseClassName {
    return @"Request";
}

- (BOOL)isEqual:(id)object {
    
    if ([object isKindOfClass:[Request class]]) {
        Request *song = (Request *)object;
        return [self.objectId isEqualToString:song.objectId];
    }
    
    return NO;
}

@end
