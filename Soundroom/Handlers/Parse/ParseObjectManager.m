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
#import "Request.h"
#import "Upvote.h"
#import "Downvote.h"
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
    [self deleteObjectsInRoomWithId:roomId className:RequestClass];
    [self deleteObjectsInRoomWithId:roomId className:UpvoteClass];
    [self deleteObjectsInRoomWithId:roomId className:DownvoteClass];
    [self deleteObjectsInRoomWithId:roomId className:InvitationClass];
    
    // delete room
    [ParseQueryManager getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
        if (object) {
            Room *room = (Room *)object;
            [room deleteInBackground];
        }
    }];
    
}

# pragma mark - Request

+ (void)createSongRequestInCurrentRoomWithSpotifyId:(NSString *)spotifyId {
    
    NSString *currentRoomId = [[RoomManager shared] currentRoomId];
    
    if (currentRoomId) {
        Request *newSong = [Request new];
        newSong.spotifyId = spotifyId;
        newSong.roomId = currentRoomId;
        [newSong saveInBackground];
    }
    
}

+ (void)deleteRequestWithId:(NSString *)requestId {
    
    // delete request
    [ParseQueryManager getSongWithId:requestId completion:^(PFObject *object, NSError *error) {
        [object deleteInBackground];
    }];
    
    // delete attached upvotes
    [ParseQueryManager getUpvotesForRequestWithId:requestId completion:^(NSArray *objects, NSError *error) {
        [self deleteObjects:objects];
    }];
    
    // delete attached downvotes
    [ParseQueryManager getUpvotesForRequestWithId:requestId completion:^(NSArray *objects, NSError *error) {
        [self deleteObjects:objects];
    }];
    
}

# pragma mark - Vote

+ (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId score:(NSNumber *)score {
    
    if (score.integerValue == 1) {
        [self createUpvoteByCurrentUserForRequestWithId:requestId];
        [self deleteDownvoteByCurrentUserForRequestWithId:requestId];
        return;
    }
    
    if (score.integerValue == -1) {
        [self deleteUpvoteByCurrentUserForRequestWithId:requestId];
        [self createDownvoteByCurrentUserForRequestWithId:requestId];
        return;
    }
    
    [self deleteVotesByCurrentUserForRequestWithId:requestId];
    
}

+ (void)createUpvoteByCurrentUserForRequestWithId:(NSString *)requestId {
    // check for duplicate
    [ParseQueryManager getUpvoteByCurrentUserForRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        if (!object && error.code == 101) {
            // no results matched the query
            Upvote *upvote = [Upvote new];
            upvote.requestId = requestId;
            upvote.userId = [ParseUserManager currentUserId];
            upvote.roomId = [[RoomManager shared] currentRoomId];
            [upvote saveInBackground];
        }
    }];
}

+ (void)createDownvoteByCurrentUserForRequestWithId:(NSString *)requestId {
    // check for duplicate
    [ParseQueryManager getDownvoteByCurrentUserForRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        if (!object && error.code == 101) {
            // no results matched the query
            Downvote *downvote = [Downvote new];
            downvote.requestId = requestId;
            downvote.userId = [ParseUserManager currentUserId];
            downvote.roomId = [[RoomManager shared] currentRoomId];
            [downvote saveInBackground];
        }
    }];
}

+ (void)deleteUpvoteByCurrentUserForRequestWithId:(NSString *)requestId {
    [ParseQueryManager getUpvoteByCurrentUserForRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        [object deleteInBackground];
    }];
}

+ (void)deleteDownvoteByCurrentUserForRequestWithId:(NSString *)requestId {
    [ParseQueryManager getDownvoteByCurrentUserForRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        [object deleteInBackground];
    }];
}

+ (void)deleteVotesByCurrentUserForRequestWithId:(NSString *)requestId {
    [self deleteUpvoteByCurrentUserForRequestWithId:requestId];
    [self deleteDownvoteByCurrentUserForRequestWithId:requestId];
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

+ (void)acceptInvitationWithId:(NSString *)invitationId {
    [ParseQueryManager getInvitationWithId:invitationId completion:^(PFObject *object, NSError *error) {
        if (object) {
            Invitation *invitation = (Invitation *)object;
            [invitation setValue:@(NO) forKey:isPendingKey];
            [invitation saveInBackground];
        }
    }];
}

+ (void)deleteInvitationWithId:(NSString *)invitationId {
    [ParseQueryManager getInvitationWithId:invitationId completion:^(PFObject *object, NSError *error) {
        if (object) {
            [object deleteInBackground];
        }
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
