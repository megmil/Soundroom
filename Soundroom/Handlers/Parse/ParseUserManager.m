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

# pragma mark - Search

+ (void)getUsersWithUsername:(NSString *)username completion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" matchesRegex:username modifiers:@"i"]; // ignore case
    query.limit = 20;
    [query findObjectsInBackgroundWithBlock:completion];
}

# pragma mark - Current User Data

+ (NSString *)currentUserId {
    PFUser *currentUser = [PFUser currentUser];
    return currentUser.objectId;
}

+ (BOOL)isLoggedIn {
    return [PFUser currentUser];
}

# pragma mark - Votes

+ (void)upvoteQueueSongWithId:(NSString *)queueSongId {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addUniqueObject:queueSongId forKey:@"upvotedSongIds"];
    [currentUser removeObject:queueSongId forKey:@"downvotedSongIds"];
    [currentUser saveInBackground];
}

+ (void)downvoteQueueSongWithId:(NSString *)queueSongId {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser addUniqueObject:queueSongId forKey:@"downvotedSongIds"];
    [currentUser removeObject:queueSongId forKey:@"upvotedSongIds"];
    [currentUser saveInBackground];
}

+ (void)unvoteQueueSongWithId:(NSString *)queueSongId {
    PFUser *currentUser = [PFUser currentUser];
    [currentUser removeObject:queueSongId forKey:@"downvotedSongIds"];
    [currentUser removeObject:queueSongId forKey:@"upvotedSongIds"];
    [currentUser saveInBackground];
}

@end
