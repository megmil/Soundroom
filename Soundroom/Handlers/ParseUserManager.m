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

- (void)registerWithUsername:(NSString *)username password:(NSString *)password completion:(PFBooleanResultBlock _Nullable)completion {
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self loginWithUsername:username password:password completion:completion];
        }
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password completion:(PFBooleanResultBlock _Nullable)completion {
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (!error) {
            // TODO: perform segue
        }
    }];
}

@end
