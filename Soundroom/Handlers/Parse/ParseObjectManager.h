//
//  ParseObjectManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import <Foundation/Foundation.h>
#import "Song.h" // need for VoteState

NS_ASSUME_NONNULL_BEGIN

@interface ParseObjectManager : NSObject

+ (void)createRoomWithTitle:(NSString *)title;
+ (void)createRequestInCurrentRoomWithSpotifyId:(NSString *)spotifyId;
+ (void)createInvitationToCurrentRoomForUserWithId:(NSString *)userId;

+ (void)updateCurrentRoomWithSongWithSpotifyId:(NSString *)spotifyId;
+ (void)acceptInvitationWithId:(NSString *)invitationId;
+ (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId voteState:(VoteState)voteState;

+ (void)deleteCurrentRoomAndAttachedObjects;
+ (void)deleteRequestWithId:(NSString *)requestId;
+ (void)deleteInvitationsAcceptedByCurrentUser;
+ (void)deleteInvitationWithId:(NSString *)invitationId;

@end

NS_ASSUME_NONNULL_END
