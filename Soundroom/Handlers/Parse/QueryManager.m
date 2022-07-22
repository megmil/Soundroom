//
//  QueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import "QueryManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "QueueSong.h"

@implementation QueryManager

# pragma mark - Live Queries

+ (PFQuery *)queryForInvitationsAcceptedByCurrentUser {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    [query whereKey:isPendingKey equalTo:@(NO)];
    return query;
}

+ (PFQuery *)queryForSongsInCurrentRoom {
    PFQuery *query = [PFQuery queryWithClassName:QueueSongClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    return query;
}

+ (PFQuery *)queryForVotesInCurrentRoom {
    PFQuery *query = [PFQuery queryWithClassName:VoteClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    return query;
}

# pragma mark - User

+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFUser query];
    [query whereKey:usernameKey matchesRegex:username modifiers:@"i"]; // ignore case
    [query whereKey:usernameKey notEqualTo:ParseUserManager.currentUserId]; // exclude current user
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:completion];
}

# pragma mark - Room

+ (void)getRoomWithId:(NSString *)roomId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:RoomClass];
    [query getObjectInBackgroundWithId:roomId block:completion];
}

+ (void)deleteCurrentRoomAndAttachedObjects {
    
    // store roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    // delete attached objects
    [self deleteObjectsInRoomWithId:roomId className:QueueSongClass];
    [self deleteObjectsInRoomWithId:roomId className:VoteClass];
    [self deleteObjectsInRoomWithId:roomId className:InvitationClass];
    
    // delete room
    [self getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
        if (object) {
            Room *room = (Room *)object;
            [room deleteInBackground];
        }
    }];
    
}

# pragma mark - Song

+ (void)getSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:QueueSongClass];
    [query getObjectInBackgroundWithId:songId block:completion];
}

+ (void)getSongsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [self queryForSongsInCurrentRoom];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getSpotifyIdForSongWithId:(NSString *)songId completion:(PFStringResultBlock)completion {
    [self getSongWithId:songId completion:^(PFObject *object, NSError *error) {
        if (object) {
            QueueSong *song = (QueueSong *)object;
            completion(song.spotifyId, error);
        } else {
            completion(nil, error);
        }
    }];
}

# pragma mark - Vote

+ (void)getVotesInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [self queryForVotesInCurrentRoom];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getVotesByCurrentUserInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:VoteClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]]; // TODO: is roomId necessary?
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getVotesForSongWithId:(NSString *)songId completion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:VoteClass];
    [query whereKey:songIdKey equalTo:songId];
    // TODO: is roomId necessary?
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getVoteByCurrentUserForSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:VoteClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    [query whereKey:songIdKey equalTo:songId];
    [query getFirstObjectInBackgroundWithBlock:completion]; // should only be one vote per song per user
}

# pragma mark - Invitation

+ (void)getInvitationAcceptedByCurrentUserWithCompletion:(PFObjectResultBlock)completion {
    PFQuery *query = [self queryForInvitationsAcceptedByCurrentUser];
    [query getFirstObjectInBackgroundWithBlock:completion]; // should only be one accepted invitation per user
}

+ (void)getInvitationsAcceptedForCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    [query whereKey:isPendingKey equalTo:@(NO)];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getInvitationsForCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)didSendCurrentRoomInvitationToUserWithId:(NSString *)userId completion:(PFBooleanResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:userIdKey equalTo:userId];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && objects.count) {
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

+ (void)deleteInvitationsAcceptedByCurrentUser {
    [self getInvitationsAcceptedForCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        [self deleteObjects:objects];
    }];
}

+ (void)deleteInvitationsForCurrentRoom {
    [self getInvitationsForCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        [self deleteObjects:objects];
    }];
}

# pragma mark - Helpers

+ (void)deleteObjectsInRoomWithId:(NSString *)roomId className:(NSString *)className {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:roomIdKey equalTo:roomId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self deleteObjects:objects];
    }];
}

+ (void)deleteObjects:(NSArray *)objects {
    for (PFObject *object in objects) {
        [object deleteInBackground];
    }
}

@end
