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
@dynamic currentSongSpotifyId;

+ (nonnull NSString *)parseClassName {
    return @"Room";
}

- (instancetype)initWithTitle:(NSString *)title hostId:(NSString *)hostId {
    
    self = [super init];
    
    if (self) {
        self.title = title;
        self.hostId = hostId;
    }
    
    return self;
    
}

@end
