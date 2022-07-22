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

+ (void)deleteAllObjectsInCurrentRoom {
    [self deleteAllObjectsInCurrentRoomWithClassName:QueueSongClass];
    [self deleteAllObjectsInCurrentRoomWithClassName:VoteClass];
    [self deleteAllObjectsInCurrentRoomWithClassName:InvitationClass];
}

# pragma mark - Song

+ (void)getSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:QueueSongClass];
    [query getObjectInBackgroundWithId:songId block:completion];
}

+ (void)getSongsInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:QueueSongClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
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
    PFQuery *query = [PFQuery queryWithClassName:VoteClass];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getVotesByCurrentUserInCurrentRoomWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:VoteClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:completion];
}

# pragma mark - Invitation

+ (void)getInvitationAcceptedByCurrentUserWithCompletion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:RoomClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
    [query whereKey:isPendingKey equalTo:@(NO)];
    query.limit = 1; // should only be one accepted invitation per user
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        completion(objects.firstObject, error);
    }];
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

+ (void)deleteAllObjectsInCurrentRoomWithClassName:(NSString *)className {
    PFQuery *query = [PFQuery queryWithClassName:className];
    [query whereKey:roomIdKey equalTo:[[RoomManager shared] currentRoomId]];
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
