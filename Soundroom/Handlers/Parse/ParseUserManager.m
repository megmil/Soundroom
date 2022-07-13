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

# pragma mark - Server

+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" matchesRegex:username modifiers:@"i"]; // ignore case
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:completion];
}

+ (void)getUserWithId:(NSString *)userId completion:(PFObjectResultBlock)completion {
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:userId block:completion];
}

@end
