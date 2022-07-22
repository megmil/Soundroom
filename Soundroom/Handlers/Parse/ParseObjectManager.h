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
+ (void)createInvitationToCurrentRoomForUserWithId:(NSString *)userId;

+ (void)updateCurrentRoomWithCurrentSongId:(NSString *)currentSongId;
+ (void)updateCurrentUserVoteForSongWithId:(NSString *)songId score:(NSNumber *)score;

+ (void)deleteCurrentRoomAndAttachedObjects;
+ (void)deleteInvitationsAcceptedByCurrentUser;
+ (void)deleteInvitationsForCurrentRoom;

@end

NS_ASSUME_NONNULL_END
