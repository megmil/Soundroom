//
//  Invitations.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "Invitation.h"

@implementation Invitation

@dynamic objectId;
@dynamic userId;
@dynamic roomId;
@dynamic isPending;

+ (nonnull NSString *)parseClassName {
    return @"Invitation";
}

@end
