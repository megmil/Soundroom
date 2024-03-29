//
//  QueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import "ParseQueryManager.h"
#import "ParseUserManager.h"
#import "ParseConstants.h"
#import "RoomManager.h"

static const NSInteger searchLimit = 20;

@implementation ParseQueryManager

# pragma mark - Live Queries

+ (PFQuery *)queryForInvitationsForCurrentUser {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    return query;
}

+ (PFQuery *)queryForRequestsInCurrentRoom {
    PFQuery *query = [PFQuery queryWithClassName:RequestClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    return query;
}

+ (PFQuery *)queryForUpvotesInCurrentRoom {
    PFQuery *query = [PFQuery queryWithClassName:UpvoteClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    return query;
}

+ (PFQuery *)queryForDownvotesInCurrentRoom {
    PFQuery *query = [PFQuery queryWithClassName:DownvoteClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    return query;
}

+ (PFQuery *)queryForCurrentRoom {
    PFQuery *query = [PFQuery queryWithClassName:RoomClass];
    [query whereKey:objectIdKey equalTo:[[RoomManager shared] currentRoomId]];
    return query;
}

# pragma mark - User

+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFUser query];
    [query whereKey:usernameKey matchesRegex:username modifiers:@"i"]; // ignore case
    [query whereKey:objectIdKey notEqualTo:ParseUserManager.currentUserId]; // exclude current user
    query.limit = searchLimit;
    [query findObjectsInBackgroundWithBlock:completion];
}

# pragma mark - Room

+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:RoomClass];
    [query getObjectInBackgroundWithId:roomId block:completion];
}

# pragma mark - Request

+ (void)getRequestWithId:(NSString *)requestId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:RequestClass];
    [query getObjectInBackgroundWithId:requestId block:completion];
}

+ (void)getRequestsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [self queryForRequestsInCurrentRoom];
    [query orderByAscending:createdAtKey];
    [query findObjectsInBackgroundWithBlock:completion];
}

# pragma mark - Vote

+ (void)getUpvotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [self queryForUpvotesInCurrentRoom];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getDownvotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [self queryForDownvotesInCurrentRoom];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getUpvotesForRequestWithId:(NSString *)requestId completion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:UpvoteClass];
    [query whereKey:requestIdKey equalTo:requestId];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getDownvotesForRequestWithId:(NSString *)requestId completion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:DownvoteClass];
    [query whereKey:requestIdKey equalTo:requestId];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getUpvoteByCurrentUserForRequestWithId:(NSString *)requestId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:UpvoteClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    [query whereKey:requestIdKey equalTo:requestId];
    [query getFirstObjectInBackgroundWithBlock:completion]; // should only be 1 vote per user per request
}

+ (void)getDownvoteByCurrentUserForRequestWithId:(NSString *)requestId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:DownvoteClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    [query whereKey:requestIdKey equalTo:requestId];
    [query getFirstObjectInBackgroundWithBlock:completion]; // should only be 1 vote per user per request
}

# pragma mark - Invitation

+ (void)getInvitationWithId:(NSString *)invitationId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query getObjectInBackgroundWithId:invitationId block:completion];
}

+ (void)getInvitationAcceptedByCurrentUserWithCompletion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    [query whereKey:isPendingKey equalTo:@(NO)];
    [query getFirstObjectInBackgroundWithBlock:completion]; // should only be one accepted invitation per user
}

+ (void)getInvitationsForCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getInvitationsPendingForCurrentUserWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [self queryForInvitationsForCurrentUser];
    [query whereKey:isPendingKey equalTo:@(YES)];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)didSendCurrentRoomInvitationToUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:userIdKey equalTo:userId];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && objects.count != 0) {
            // user has already been invited to room
            completion(YES, error);
        } else {
            // user has not yet been invited to room
            completion(NO, error);
        }
    }];
}

+ (void)didCurrentUserAcceptRoomInvitationWithCompletion:(PFBooleanResultBlock)completion {
    [self getInvitationAcceptedByCurrentUserWithCompletion:^(PFObject *object, NSError *error) {
        if (object) {
            completion(YES, error);
        } else {
            completion(NO, error);
        }
    }];
}

@end
