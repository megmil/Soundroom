//
//  ParseUserManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseUserManager.h"

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
    [PFUser logInWithUsernameInBackground:username password:password block:completion];
}

+ (void)logoutWithCompletion:(PFUserLogoutResultBlock)completion {
    [PFUser logOutInBackgroundWithBlock:completion];
}

# pragma mark - Current User Data

+ (NSString *)currentUserId {
    PFUser *currentUser = [PFUser currentUser];
    return currentUser.objectId;
}

+ (BOOL)isLoggedIn {
    return [PFUser currentUser];
}

@end
