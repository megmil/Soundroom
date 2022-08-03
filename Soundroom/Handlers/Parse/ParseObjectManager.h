//
//  ParseObjectManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import <Foundation/Foundation.h>
#import "EnumeratedTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseObjectManager : NSObject

+ (void)createRoomWithTitle:(NSString *)title listeningMode:(RoomListeningModeType)listeningMode;
+ (void)updateCurrentRoomWithISRC:(NSString *)isrc;
+ (void)deleteCurrentRoomAndAttachedObjects;

+ (void)createRequestInCurrentRoomWithISRC:(NSString *)isrc deezerId:(NSString *)deezerId;
+ (void)deleteRequestWithId:(NSString *)requestId;

+ (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;

+ (void)createInvitationToCurrentRoomForUserWithId:(NSString *)userId;
+ (void)acceptInvitationWithId:(NSString *)invitationId;
+ (void)deleteInvitationsAcceptedByCurrentUser;
+ (void)deleteInvitationWithId:(NSString *)invitationId;

@end

NS_ASSUME_NONNULL_END
