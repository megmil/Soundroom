//
//  ParseUserManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseUserManager : NSObject

+ (void)registerWithUsername:(NSString *)username password:(NSString *)password completion:(PFUserResultBlock)completion;
+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(PFUserResultBlock)completion;
+ (void)logoutWithCompletion:(PFUserLogoutResultBlock)completion;

+ (NSString *)currentUserId;
+ (NSString *)currentUsername;
+ (BOOL)isLoggedIn;
+ (BOOL)isCurrentUserInRoom;
+ (BOOL)isCurrentUserHost;
+ (BOOL)isCurrentUserPlayingMusic;

+ (UIImage *)avatarImageForCurrentUser;
+ (UIImage *)avatarImageForUser:(PFUser *)user;

@end

NS_ASSUME_NONNULL_END
