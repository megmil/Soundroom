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

- (instancetype)initWithSpotifyId:(NSString *)spotifyId roomId:(NSString *)roomId userId:(NSString *)userId {
    
    self = [super init];
    
    if (self) {
        self.spotifyId = spotifyId;
        self.roomId = roomId;
        self.userId = userId;
    }
    
    return self;
    
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[Request class]]) {
        Request *request = (Request *)object;
        return [self.objectId isEqualToString:request.objectId];
    }
    return NO;
}

@end
