//
//  ParseUserManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseUserManager.h"
#import "ParseLiveQueryManager.h"
#import "SpotifySessionManager.h"

@implementation ParseUserManager

# pragma mark - Authentication

+ (void)registerWithUsername:(NSString *)username password:(NSString *)password completion:(PFUserResultBlock)completion {
    
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
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
            [[SpotifySessionManager shared] signOut];
            [[ParseLiveQueryManager shared] clearUserLiveSubscriptions];
            completion(nil);
        } else {
            completion(error);
        }
    }];
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
    return [PFUser currentUser];
}

@end
