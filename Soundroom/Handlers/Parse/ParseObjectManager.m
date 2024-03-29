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
#import "DeezerAPIManager.h"
#import "RoomManager.h"
#import "Room.h"
#import "Request.h"
#import "Upvote.h"
#import "Downvote.h"
#import "Invitation.h"

@implementation ParseObjectManager

# pragma mark - Room

+ (void)createRoomWithTitle:(NSString *)title listeningMode:(RoomListeningMode)listeningMode {
    
    NSString *userId = [ParseUserManager currentUserId];
    
    if (userId == nil || userId.length == 0) {
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

+ (void)updateCurrentRoomWithISRC:(NSString *)isrc {
    
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (roomId == nil || roomId.length == 0) {
        return;
    }
    
    [ParseQueryManager getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
        if (object != nil) {
            Room *room = (Room *)object;
            [room setValue:isrc forKey:currentSongISRCKey];
            [room saveInBackground];
        }
    }];
}

+ (void)deleteCurrentRoomAndAttachedObjects {
    
    // store roomId
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    // delete room
    [ParseQueryManager getRoomWithId:roomId completion:^(PFObject *object, NSError *error) {
        if (object) {
            Room *room = (Room *)object;
            [room deleteInBackground];
        }
    }];
    
    // delete attached objects
    [self deleteObjectsInRoomWithId:roomId className:RequestClass];
    [self deleteObjectsInRoomWithId:roomId className:UpvoteClass];
    [self deleteObjectsInRoomWithId:roomId className:DownvoteClass];
    [self deleteObjectsInRoomWithId:roomId className:InvitationClass];
    
}

# pragma mark - Request

+ (void)createRequestInCurrentRoomWithISRC:(NSString *)isrc deezerId:(NSString *)deezerId {
    
    NSString *userId = [ParseUserManager currentUserId];
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (userId == nil || roomId == nil || userId.length == 0 || roomId.length == 0) {
        return;
    }
    
    if (isrc != nil || isrc.length != 0) {
        Request *newRequest = [[Request alloc] initWithISRC:isrc roomId:roomId userId:userId];
        [newRequest saveInBackground];
        return;
    }
    
    if (deezerId == nil) {
        return;
    }
    
    [[DeezerAPIManager shared] getISRCWithDeezerId:deezerId completion:^(NSString *isrc) {
        Request *newRequest = [[Request alloc] initWithISRC:isrc roomId:roomId userId:userId];
        [newRequest saveInBackground];
    }];
    
}

+ (void)deleteRequestWithId:(NSString *)requestId {
    
    // delete request
    [ParseQueryManager getRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
            if (succeeded) {
                
                // delete attached upvotes
                [ParseQueryManager getUpvotesForRequestWithId:requestId completion:^(NSArray *objects, NSError *error) {
                    [self deleteObjects:objects];
                }];
                
                // delete attached downvotes
                [ParseQueryManager getDownvotesForRequestWithId:requestId completion:^(NSArray *objects, NSError *error) {
                    [self deleteObjects:objects];
                }];
                
                
            }
            
        }];
        
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
    
    if (requestId == nil || userId == nil || roomId == nil || requestId.length == 0 || userId.length == 0 || roomId.length == 0) {
        return;
    }
    
    // check for duplicate
    [ParseQueryManager getUpvoteByCurrentUserForRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        if (object == nil && error.code == 101) {
            // no results matched the query
            Upvote *upvote = [[Upvote alloc] initWithRequestId:requestId userId:userId roomId:roomId];
            [upvote saveInBackground];
        }
    }];
}

+ (void)createDownvoteByCurrentUserForRequestWithId:(NSString *)requestId {
    
    NSString *userId = [ParseUserManager currentUserId];
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (requestId == nil || userId == nil || roomId == nil || requestId.length == 0 || userId.length == 0 || roomId.length == 0) {
        return;
    }
    
    // check for duplicate
    [ParseQueryManager getDownvoteByCurrentUserForRequestWithId:requestId completion:^(PFObject *object, NSError *error) {
        if (object == nil && error.code == 101) {
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
    
    if (userId == nil || roomId == nil || userId.length == 0 || roomId.length == 0) {
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
    
    if (userId == nil || roomId == nil || userId.length == 0 || roomId.length == 0) {
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
    [ParseQueryManager getInvitationAcceptedByCurrentUserWithCompletion:^(PFObject *object, NSError *error) {
        [object deleteInBackground];
    }];
}

+ (void)acceptInvitationWithId:(NSString *)invitationId {
    [ParseQueryManager getInvitationWithId:invitationId completion:^(PFObject *object, NSError *error) {
        if (object != nil) {
            Invitation *invitation = (Invitation *)object;
            [invitation setValue:@(NO) forKey:isPendingKey];
            [invitation saveInBackground];
        }
    }];
}

+ (void)deleteInvitationWithId:(NSString *)invitationId {
    [ParseQueryManager getInvitationWithId:invitationId completion:^(PFObject *object, NSError *error) {
        if (object != nil) {
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
