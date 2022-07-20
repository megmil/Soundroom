//
//  InvitationManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface InvitationManager : NSObject

+ (void)inviteUserWithId:(NSString *)userId;
+ (void)registerHostForRoomWithId:(NSString *)roomId;
+ (void)deleteAcceptedInvitations;
+ (void)removeAllMembersFromRoom;

@end

NS_ASSUME_NONNULL_END
