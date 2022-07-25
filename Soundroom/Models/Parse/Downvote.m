//
//  Downvote.m
//  Soundroom
//
//  Created by Megan Miller on 7/23/22.
//

#import "Downvote.h"

@implementation Downvote

@dynamic objectId;
@dynamic requestId;
@dynamic roomId;
@dynamic userId;

+ (nonnull NSString *)parseClassName {
    return @"Downvote";
}

@end
