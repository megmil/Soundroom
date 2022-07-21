//
//  QueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import "SNDParseManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"

@implementation SNDParseManager

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

+ (void)deleteAllObjects:(NSArray *)objects {
    for (PFObject *object in objects) {
        [object deleteInBackground];
    }
}

- (PFQuery *)queryForAcceptedInvitations {
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"userId" equalTo:[ParseUserManager currentUserId]];
    [query whereKey:@"isPending" equalTo:@(NO)];
    return query;
}

- (PFQuery *)queryForAllRoomMembers {
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    [query whereKey:@"isPending" equalTo:@(NO)];
    return query;
}

- (PFQuery *)queryForCurrentQueue {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    return query;
}

- (PFQuery *)queryForScoreUpdates {
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    return query;
}

+ (PFQuery *)queryForUserVotesWithSongId:(NSString *)songId {
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"userId" equalTo:[ParseUserManager currentUserId]];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    [query whereKey:@"songId" equalTo:songId];
    return query;
}

+ (PFQuery *)queryForAllVotesWithSongId:(NSString *)songId {
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    [query whereKey:@"songId" equalTo:songId];
    return query;
}

@end
