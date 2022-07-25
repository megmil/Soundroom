//
//  ParseObjectManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseObjectManager : NSObject

+ (void)createRoomWithTitle:(NSString *)title;
+ (void)createSongRequestInCurrentRoomWithSpotifyId:(NSString *)spotifyId;
+ (void)createInvitationToCurrentRoomForUserWithId:(NSString *)userId;

+ (void)updateCurrentRoomWithCurrentSongId:(NSString *)currentSongId;
+ (void)acceptInvitationWithId:(NSString *)invitationId;
+ (void)updateCurrentUserVoteForRequestWithId:(NSString *)requestId score:(NSNumber *)score;

+ (void)deleteCurrentRoomAndAttachedObjects;
+ (void)deleteRequestWithId:(NSString *)requestId;
+ (void)deleteInvitationsAcceptedByCurrentUser;
+ (void)deleteInvitationWithId:(NSString *)invitationId;

@end

NS_ASSUME_NONNULL_END
