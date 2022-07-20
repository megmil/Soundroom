//
//  Invitations.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "Invitation.h"
#import "ParseUserManager.h"
#import "RoomManager.h"

@implementation Invitation

@dynamic objectId;
@dynamic userId;
@dynamic roomId;
@dynamic isPending;

+ (nonnull NSString *)parseClassName {
    return @"Invitation";
}

+ (void)inviteUserWithId:(NSString *)userId {
    
    NSString *roomId = [[CurrentRoomManager shared] currentRoomId];
    
    // check for duplicate
    [self didInviteUserWithId:userId roomId:roomId completion:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            // user has not yet been invited
            Invitation *newInvitation = [Invitation new];
            newInvitation.userId = userId;
            newInvitation.roomId = roomId;
            newInvitation.isPending = YES;
            [newInvitation saveInBackground];
        }
    }];
    
}

+ (void)didInviteUserWithId:(NSString *)userId roomId:(NSString *)roomId completion:(PFBooleanResultBlock)completion {
    
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

- (void)isInRoomWithCompletion:(PFBooleanResultBlock)completion {
    
    NSString *userId = [ParseUserManager currentUserId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Invitation"];
    [query whereKey:@"userId" equalTo:userId];
    [query whereKey:@"isPending" equalTo:@(NO)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            // user is already in a room
            completion(YES, error);
        } else {
            // user is not already in a room
            completion(NO, error);
        }
    }];
}

- (void)rejectInvitation {
    [self deleteEventually];
}

@end
