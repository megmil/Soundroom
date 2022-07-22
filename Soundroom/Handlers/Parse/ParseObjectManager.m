//
//  ParseObjectManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import "ParseObjectManager.h"
#import "ParseUserManager.h"
#import "ParseQueryManager.h"
#import "RoomManager.h"
#import "Room.h"
#import "QueueSong.h"
#import "Vote.h"
#import "Invitation.h"

@implementation ParseObjectManager

# pragma mark - Room

+ (void)createRoomWithTitle:(NSString *)title {
    // create room
    Room *newRoom = [Room new];
    newRoom.title = title;
    newRoom.hostId = [ParseUserManager currentUserId];
    [newRoom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // create accepted invitation for host
            [self createAcceptedInvitationForCurrentUserToRoomWithId:newRoom.objectId];
        }
    }];
}

+ (void)updateCurrentRoomWithCurrentSongId:(NSString *)currentSongId {
    [ParseQueryManager getRoomWithId:[[RoomManager shared] currentRoomId] completion:^(PFObject *object, NSError *error) {
        if (object) {
            Room *room = (Room *)object;
            [room setValue:currentSongId forKey:currentSongIdKey];
            [room saveInBackground];
        }
    }];
}

+ (void)deleteCurrentRoomAndAttachedObjects {
    
    // store roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    // delete attached objects
    [self deleteObjectsInRoomWithId:roomId className:QueueSongClass];
    [self deleteObjectsInRoomWithId:roomId className:VoteClass];
    [self deleteObjectsInRoomWithId:roomId className:InvitationClass];
    
    // delete room
    [ParseQueryManager getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
        if (object) {
            Room *room = (Room *)object;
            [room deleteInBackground];
        }
    }];
    
}

# pragma mark - QueueSong

+ (void)createSongRequestInCurrentRoomWithSpotifyId:(NSString *)spotifyId {
    
    NSString *currentRoomId = [[RoomManager shared] currentRoomId];
    
    if (currentRoomId) {
        QueueSong *newSong = [QueueSong new];
        newSong.spotifyId = spotifyId;
        newSong.roomId = currentRoomId;
        [newSong saveInBackground];
    }
    
}


# pragma mark - Vote

+ (void)updateCurrentUserVoteForSongWithId:(NSString *)songId score:(NSNumber *)score {
    // check for previous vote
    [ParseQueryManager getVoteByCurrentUserForSongWithId:songId completion:^(PFObject *object, NSError *error) {
        if (object) {
            // update duplicate vote
            Vote *vote = (Vote *)object;
            vote.increment = score;
            [vote saveInBackground];
        } else {
            [self createCurrentUserVoteForSongWithId:songId score:score];
        }
    }];
}

+ (void)createCurrentUserVoteForSongWithId:(NSString *)songId score:(NSNumber *)score {
    Vote *newVote = [Vote new];
    newVote.songId = songId;
    newVote.userId = [ParseUserManager currentUserId];
    newVote.roomId = [[RoomManager shared] currentRoomId];
    newVote.increment = score;
    [newVote saveInBackground];
}

# pragma mark - Invitation

+ (void)createInvitationToCurrentRoomForUserWithId:(NSString *)userId {
    // check for duplicate invite
    [ParseQueryManager didSendCurrentRoomInvitationToUserWithId:userId completion:^(BOOL isDuplicate, NSError *error) {
        if (!isDuplicate) {
            // user has not yet been invited
            Invitation *newInvitation = [Invitation new];
            newInvitation.userId = userId;
            newInvitation.roomId = [[RoomManager shared] currentRoomId];
            newInvitation.isPending = YES;
            [newInvitation saveInBackground];
        }
    }];
}

+ (void)createAcceptedInvitationForCurrentUserToRoomWithId:(NSString *)roomId {
    [ParseQueryManager didCurrentUserAcceptRoomInvitationWithCompletion:^(BOOL isInRoom, NSError * _Nullable error) {
        if (!isInRoom) {
            // user has not yet joined a room
            Invitation *newInvitation = [Invitation new];
            newInvitation.userId = [ParseUserManager currentUserId];
            newInvitation.roomId = roomId;
            newInvitation.isPending = NO;
            [newInvitation saveInBackground];
        }
    }];
}

+ (void)deleteInvitationsAcceptedByCurrentUser {
    [ParseQueryManager getInvitationsAcceptedForCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
        [self deleteObjects:objects];
    }];
}

+ (void)deleteInvitationsForCurrentRoom {
    [ParseQueryManager getInvitationsForCurrentRoomWithCompletion:^(NSArray *objects, NSError *error) {
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
