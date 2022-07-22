//
//  QueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import "QueryManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"

@implementation QueryManager

# pragma mark - User

# pragma mark - Room

# pragma mark - Song

+ (void)getSongsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:completion];
}

# pragma mark - Vote

+ (void)getVotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getVotesByCurrentUserInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"userId" equalTo:[ParseUserManager currentUserId]];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:completion];
}

# pragma mark - Invitation

+ (void)getInvitationsAcceptedByCurrentUserWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"userId" equalTo:[ParseUserManager currentUserId]];
    [query whereKey:@"isPending" equalTo:@(NO)];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getInvitationsAcceptedForCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"roomId" equalTo:[[RoomManager shared] currentRoomId]];
    [query whereKey:@"isPending" equalTo:@(NO)];
    [query findObjectsInBackgroundWithBlock:completion];
}

@end
