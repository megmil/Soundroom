//
//  Upvotes.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "Upvote.h"

@implementation Upvote

@dynamic objectId;
@dynamic requestId;
@dynamic roomId;
@dynamic userId;

+ (nonnull NSString *)parseClassName {
    return @"Upvote";
}

@end
