//
//  InvitationManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import "InvitationManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "QueryManager.h"
#import "Invitation.h"
#import "QueryManager.h"

@implementation InvitationManager

+ (void)inviteUserWithId:(NSString *)userId {
    // check for duplicate invite
    [QueryManager didSendCurrentRoomInvitationToUserWithId:userId completion:^(BOOL isDuplicate, NSError *error) {
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

+ (void)registerHostForRoomWithId:(NSString *)roomId {
    [QueryManager didCurrentUserAcceptRoomInvitationWithCompletion:^(BOOL isInRoom, NSError * _Nullable error) {
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

@end
