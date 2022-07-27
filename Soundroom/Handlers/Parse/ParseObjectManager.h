//
//  ParseObjectManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import <Foundation/Foundation.h>
#import "Room.h" // need for RoomListeningModeType
#import "Song.h" // need for VoteState

NS_ASSUME_NONNULL_BEGIN

@interface ParseObjectManager : NSObject

+ (void)createRoomWithTitle:(NSString *)title listeningMode:(RoomListeningModeType)listeningMode;
+ (void)updateCurrentRoomWithSongWithSpotifyId:(NSString *)spotifyId; // TODO: rename
+ (void)deleteCurrentRoomAndAttachedObjects;

+ (void)createRequestInCurrentRoomWithSpotifyId:(NSString *)spotifyId;
+ (void)deleteRequestWithId:(NSString *)requestId;

+ (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;

+ (void)createInvitationToCurrentRoomForUserWithId:(NSString *)userId;
+ (void)acceptInvitationWithId:(NSString *)invitationId;
+ (void)deleteInvitationsAcceptedByCurrentUser;
+ (void)deleteInvitationWithId:(NSString *)invitationId;

@end

NS_ASSUME_NONNULL_END
