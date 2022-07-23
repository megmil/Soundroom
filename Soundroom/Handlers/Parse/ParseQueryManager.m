//
//  QueryManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/21/22.
//

#import "ParseQueryManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "Room.h"
#import "QueueSong.h" // TODO: move logic that requires QueueSong import?

@implementation ParseQueryManager

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

+ (void)getRoomsWithPendingInvitationsToCurrentUserWithCompletion:(PFArrayResultBlock)completion {
    
    [self getInvitationsForCurrentUserWithCompletion:^(NSArray *objects, NSError *error) {
        
        if (!objects || !objects.count) {
            completion(nil, error);
            return;
        }
        
        NSArray <Invitation *> *invitations = objects;
        __block NSMutableArray <Room *> *rooms = [NSMutableArray <Room *> array];
        
        for (NSUInteger i = 0; i != invitations.count; i++) {
            
            [self getRoomWithId:invitations[i].roomId completion:^(PFObject *object, NSError *error) {
                
                if (object) {
                    
                    Room *room = (Room *)object;
                    [rooms addObject:room];
                    
                    if (i + 1 == invitations.count) {
                        completion(rooms, error);
                    }
                    
                }
                
            }];
            
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

+ (void)getInvitationWithId:(NSString *)invitationId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query getObjectInBackgroundWithId:invitationId block:completion];
}

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

+ (void)getInvitationsForCurrentUserWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:InvitationClass];
    [query whereKey:userIdKey equalTo:[ParseUserManager currentUserId]];
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

@end
