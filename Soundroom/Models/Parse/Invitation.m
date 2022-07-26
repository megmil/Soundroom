//
//  Invitations.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "Invitation.h"
#import "ParseConstants.h"

@implementation Invitation

@dynamic objectId;
@dynamic userId;
@dynamic roomId;
@dynamic isPending;

+ (nonnull NSString *)parseClassName {
    return InvitationClass;
}

- (instancetype)initWithUserId:(NSString *)userId roomId:(NSString *)roomId isPending:(BOOL)isPending {
    
    self = [super init];
    
    if (self) {
        self.userId = userId;
        self.roomId = roomId;
        self.isPending = isPending;
    }
    
    return self;
    
}

@end
