//
//  InvitationManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import "InvitationManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "Invitation.h"

@implementation InvitationManager

+ (void)inviteUserWithId:(NSString *)userId {
    
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    // check for duplicate
    [self isDuplicateInvitationForUserWithId:userId roomId:roomId completion:^(BOOL isDuplicate, NSError *error) {
        if (!isDuplicate) {
            // user has not yet been invited
            Invitation *newInvitation = [Invitation new];
            newInvitation.userId = userId;
            newInvitation.roomId = roomId;
            newInvitation.isPending = YES;
            [newInvitation saveInBackground];
        }
    }];
    
}

+ (void)registerHostForRoomWithId:(NSString *)roomId {
    
    NSString *userId = [ParseUserManager currentUserId];
    
    // check for duplicate
    [self didJoinRoomForUserId:userId completion:^(BOOL didJoinRoom, NSError *error) {
        if (!didJoinRoom) {
            // user has not yet joined a room
            Invitation *newInvitation = [Invitation new];
            newInvitation.userId = userId;
            newInvitation.roomId = roomId;
            newInvitation.isPending = NO;
            [newInvitation saveInBackground];
        }
    }];
    
}

+ (void)didJoinRoomForUserId:userId completion:(PFBooleanResultBlock)completion {
    
    PFQuery *query = [self queryForAcceptedInvitations];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects && objects.count) {
            // user has joined a room
            completion(YES, error);
        } else {
            // user has not yet joined a room
            completion(NO, error);
        }
    }];
    
}

+ (void)isDuplicateInvitationForUserWithId:(NSString *)userId roomId:(NSString *)roomId completion:(PFBooleanResultBlock)completion {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"userId" equalTo:userId];
    [query whereKey:@"roomId" equalTo:roomId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            // user has already been invited to room
            completion(YES, error);
        } else {
            // user has not yet been invited to room
            completion(NO, error);
        }
    }];
}

/*
- (void)acceptInvitation {
    // check if user is already in a room
    [self isInRoomWithCompletion:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            // user is not already in a room
            self.isPending = NO;
            [self saveInBackground];
        } else {
            // TODO: leave current room notification
        }
    }];
}

- (void)rejectInvitation {
    [self deleteEventually];
}

 */

+ (PFQuery *)queryForAcceptedInvitations {
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"userId" equalTo:[ParseUserManager currentUserId]];
    [query whereKey:@"isPending" equalTo:@(NO)];
    return query;
}

@end
