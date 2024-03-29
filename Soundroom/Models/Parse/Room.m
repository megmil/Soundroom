//
//  Room.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Room.h"
#import "ParseConstants.h"

@implementation Room

@dynamic objectId;
@dynamic hostId;
@dynamic currentSongISRC;
@dynamic title;
@dynamic listeningMode;

+ (nonnull NSString *)parseClassName {
    return RoomClass;
}

- (instancetype)initWithTitle:(NSString *)title hostId:(NSString *)hostId listeningMode:(RoomListeningMode)listeningMode {
    
    self = [super init];
    
    if (self) {
        self.hostId = hostId;
        self.title = title;
        self.listeningMode = listeningMode;
    }
    
    return self;
    
}

@end
