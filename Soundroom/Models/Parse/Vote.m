//
//  Upvotes.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "Vote.h"

@implementation Vote

@dynamic objectId;
@dynamic songId;
@dynamic userId;
@dynamic roomId;
@dynamic increment;

+ (nonnull NSString *)parseClassName {
    return @"Vote";
}

@end
