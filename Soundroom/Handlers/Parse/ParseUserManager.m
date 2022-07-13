//
//  ParseUserManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ParseUserManager.h"

@implementation ParseUserManager

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password
                  completion:(PFBooleanResultBlock _Nullable)completion {
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self loginWithUsername:username password:password completion:completion];
        }
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
               completion:(PFBooleanResultBlock _Nullable)completion {
    [PFUser logInWithUsernameInBackground:username password:password
                                    block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        // TODO: completion
    }];
}

- (void)logoutWithCompletion:(void(^)(NSError * _Nullable error))completion {
    [PFUser logOutInBackgroundWithBlock:completion];
}

- (void)getUsersWithUsername:(NSString *)username completion:(void(^)(NSArray *users, NSError *error))completion {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" matchesRegex:username modifiers:@"i"]; // ignore case
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:completion];
}

@end
