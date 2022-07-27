//
//  ParseObjectManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import "ParseObjectManager.h"
#import "ParseUserManager.h"
#import "ParseQueryManager.h"
#import "ParseConstants.h"
#import "RoomManager.h"
#import "Room.h"
#import "Request.h"
#import "Upvote.h"
#import "Downvote.h"
#import "Invitation.h"

@implementation ParseObjectManager

# pragma mark - Room

+ (void)createRoomWithTitle:(NSString *)title listeningMode:(RoomListeningModeType)listeningMode {
    
    NSString *userId = [ParseUserManager currentUserId];
    
    if (!userId) {
        return;
    }
    
    Room *room = [[Room alloc] initWithTitle:title hostId:userId listeningMode:listeningMode];
    [room saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            // create accepted invitation for host
            [self createAcceptedInvitationForCurrentUserToRoomWithId:room.objectId];
        }
    }];
}

+ (void)updateCurrentRoomWithSongWithSpotifyId:(NSString *)spotifyId {
    
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (!roomId) {
        return;
    }
    
    [ParseQueryManager getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
        if (object) {
            Room *room = (Room *)object;
            [room setValue:spotifyId forKey:currentSongSpotifyIdKey];
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

+ (void)createRequestInCurrentRoomWithSpotifyId:(NSString *)spotifyId {
    
    NSString *userId = [ParseUserManager currentUserId];
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (!spotifyId || !userId || !roomId) {
        return;
    }
    
    Request *newRequest = [[Request alloc] initWithSpotifyId:spotifyId roomId:roomId userId:userId];
    [newRequest saveInBackground];
    
}

+ (void)deleteRequestWithId:(NSString *)requestId {
    
    // delete request
    [ParseQueryManager getRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        [object deleteInBackground];
    }];
    
    // delete attached upvotes
    [ParseQueryManager getUpvotesForRequestWithId:requestId completion:^(NSArray *objects, NSError *error) {
        [self deleteObjects:objects];
    }];
    
    // delete attached downvotes
    [ParseQueryManager getDownvotesForRequestWithId:requestId completion:^(NSArray *objects, NSError *error) {
        [self deleteObjects:objects];
    }];
    
}

# pragma mark - Vote

+ (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState {
    
    if (voteState == Upvoted) {
        [self createUpvoteByCurrentUserForRequestWithId:requestId];
        [self deleteDownvoteByCurrentUserForRequestWithId:requestId];
        return;
    }
    
    if (voteState == Downvoted) {
        [self deleteUpvoteByCurrentUserForRequestWithId:requestId];
        [self createDownvoteByCurrentUserForRequestWithId:requestId];
        return;
    }
    
    [self deleteVotesByCurrentUserForRequestWithId:requestId];
    
}

+ (void)createUpvoteByCurrentUserForRequestWithId:(NSString *)requestId {
    
    NSString *userId = [ParseUserManager currentUserId];
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (!requestId || !userId || !roomId) {
        return;
    }
    
    // check for duplicate
    [ParseQueryManager getUpvoteByCurrentUserForRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        if (!object && error.code == 101) {
            // no results matched the query
            Upvote *upvote = [[Upvote alloc] initWithRequestId:requestId userId:userId roomId:roomId];
            [upvote saveInBackground];
        }
    }];
}

+ (void)createDownvoteByCurrentUserForRequestWithId:(NSString *)requestId {
    
    NSString *userId = [ParseUserManager currentUserId];
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (!requestId || !userId || !roomId) {
        return;
    }
    
    // check for duplicate
    [ParseQueryManager getDownvoteByCurrentUserForRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        if (!object && error.code == 101) {
            // no results matched the query
            Downvote *downvote = [[Downvote alloc] initWithRequestId:requestId userId:userId roomId:roomId];
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
    
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (!userId || !roomId) {
        return;
    }
    
    // check for duplicate invite
    [ParseQueryManager didSendCurrentRoomInvitationToUserWithId:userId completion:^(BOOL isDuplicate, NSError *error) {
        if (!isDuplicate) {
            // user has not yet been invited
            Invitation *newInvitation = [[Invitation alloc] initWithUserId:userId roomId:roomId isPending:YES];
            [newInvitation saveInBackground];
        }
    }];
}

+ (void)createAcceptedInvitationForCurrentUserToRoomWithId:(NSString *)roomId {
    
    NSString *userId = [ParseUserManager currentUserId];
    
    if (!userId || !roomId) {
        return;
    }
    
    // check for more than one accepted room invitation
    [ParseQueryManager didCurrentUserAcceptRoomInvitationWithCompletion:^(BOOL isInRoom, NSError * _Nullable error) {
        if (!isInRoom) {
            // user has not yet joined a room
            Invitation *newInvitation = [[Invitation alloc] initWithUserId:userId roomId:roomId isPending:NO];
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
