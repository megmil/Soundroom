//
//  Upvotes.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "Upvote.h"
#import "ParseConstants.h"

@implementation Upvote

@dynamic objectId;
@dynamic requestId;
@dynamic roomId;
@dynamic userId;

+ (nonnull NSString *)parseClassName {
    return UpvoteClass;
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
