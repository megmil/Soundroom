//
//  QueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import "QueryManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"

@implementation QueryManager

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (PFQuery *)queryForAcceptedInvitations {
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"userId" equalTo:[ParseUserManager currentUserId]];
    [query whereKey:@"isPending" equalTo:@(NO)];
    return query;
}

@end
