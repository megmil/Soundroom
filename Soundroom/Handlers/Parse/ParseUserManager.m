//
//  ParseUserManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseUserManager.h"
#import "ParseLiveQueryManager.h"
#import "MusicPlayerManager.h"
#import "RoomManager.h"
#import "ParseConstants.h"
#import "ImageConstants.h"

@implementation ParseUserManager

# pragma mark - Authentication

+ (void)registerWithUsername:(NSString *)username password:(NSString *)password completion:(PFUserResultBlock)completion {
    
    PFUser *newUser = [self userWithUsername:username password:password];
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self setAvatarImageForUser:newUser];
            [self loginWithUsername:username password:password completion:completion];
        } else {
            completion(nil, error);
        }
    }];
}

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(PFUserResultBlock)completion {
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            [[ParseLiveQueryManager shared] configureUserLiveSubscriptions];
            completion(user, error);
        } else {
            completion(nil, error);
        }
    }];
}

+ (void)logoutWithCompletion:(PFUserLogoutResultBlock)completion {
    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
        if (!error) {
            [[MusicPlayerManager shared] signOut];
            [[ParseLiveQueryManager shared] clearUserLiveSubscriptions];
            completion(nil);
        } else {
            completion(error);
        }
    }];
}

+ (PFUser *)userWithUsername:(NSString *)username password:(NSString *)password {
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    return newUser;
}

# pragma mark - Avatar Images

+ (void)setAvatarImageForUser:(PFUser *)user {
    NSUInteger avatarImageType = arc4random_uniform(5);
    [user setValue:@(avatarImageType) forKey:avatarImageTypeKey];
    [user saveInBackground];
}

+ (UIImage *)avatarImageForCurrentUser {
    PFUser *currentUser = [PFUser currentUser];
    return [self avatarImageForUser:currentUser];
}

+ (UIImage *)avatarImageForUser:(PFUser *)user {
    NSUInteger avatarImageType = [[user valueForKey:avatarImageTypeKey] unsignedIntegerValue];
    NSString *avatarImageName = avatarImageNames[avatarImageType];
    UIImage *avatarImage = [UIImage imageNamed:avatarImageName];
    return avatarImage;
}

# pragma mark - Current User Data

+ (NSString *)currentUsername {
    PFUser *currentUser = [PFUser currentUser];
    return currentUser.username;
}

+ (NSString *)currentUserId {
    PFUser *currentUser = [PFUser currentUser];
    return currentUser.objectId;
}

+ (BOOL)isLoggedIn {
    return [PFUser currentUser] != nil;
}

+ (BOOL)isCurrentUserInRoom {
    return [[RoomManager shared] currentRoomId] != nil;
}

+ (BOOL)isCurrentUserHost {
    
    NSString *userId = [self currentUserId];
    NSString *hostId = [[RoomManager shared] currentHostId];
    
    if (userId == nil || hostId == nil || hostId.length == 0) {
        return NO;
    }
    
    return [hostId isEqualToString:userId];
    
}

+ (BOOL)isCurrentUserPlayingMusic {
    RoomListeningMode listeningMode = [[RoomManager shared] listeningMode];
    return [self isCurrentUserHost] || listeningMode == RemoteMode;
}

@end
