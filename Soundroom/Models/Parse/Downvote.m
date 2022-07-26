//
//  Downvote.m
//  Soundroom
//
//  Created by Megan Miller on 7/23/22.
//

#import "Downvote.h"
#import "ParseConstants.h"

@implementation Downvote

@dynamic objectId;
@dynamic requestId;
@dynamic roomId;
@dynamic userId;

+ (nonnull NSString *)parseClassName {
    return DownvoteClass;
}

- (instancetype)initWithRequestId:(NSString *)requestId userId:(NSString *)userId roomId:(NSString *)roomId {
    
    self = [super init];
    
    if (self) {
        self.requestId = requestId;
        self.userId = userId;
        self.roomId = roomId;
    }
    
    return self;
    
}

@end
