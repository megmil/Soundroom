//
//  ParseObjectManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import <Foundation/Foundation.h>
#import "QueueSong.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseObjectManager : NSObject

+ (void)createRoomWithTitle:(NSString *)title;
+ (void)createSongRequestInCurrentRoomWithSpotifyId:(NSString *)spotifyId;
+ (void)createInvitationToCurrentRoomForUserWithId:(NSString *)userId;

+ (void)updateCurrentRoomWithCurrentSongId:(NSString *)currentSongId;
+ (void)updateCurrentUserVoteForSongWithId:(NSString *)songId score:(NSNumber *)score;
+ (void)acceptInvitationWithId:(NSString *)invitationId;

+ (void)deleteCurrentRoomAndAttachedObjects;
+ (void)deleteQueueSong:(QueueSong *)song;
+ (void)deleteInvitationsAcceptedByCurrentUser;
+ (void)deleteInvitationWithId:(NSString *)invitationId;

@end

NS_ASSUME_NONNULL_END
