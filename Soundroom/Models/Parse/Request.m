//
//  Request.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Request.h"

@implementation Request

@dynamic objectId;
@dynamic roomId;
@dynamic spotifyId;
@dynamic userId;

+ (nonnull NSString *)parseClassName {
    return @"Request";
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Request class]]) {
        Request *request = (Request *)object;
        return [self.objectId isEqualToString:request.objectId];
    }
    return NO;
}

@end
