//
//  SceneDelegate.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SceneDelegate.h"
#import "SpotifyAuthClient.h"
#import "LoginViewController.h"
#import "Parse/Parse.h"
#import "ParseLiveQueryManager.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![PFUser currentUser]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"UserLoginViewController"];
        self.window.rootViewController = userLoginVC;
    }
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.allObjects.firstObject.URL;
    [[SpotifyAuthClient shared] retrieveCodeFromUrl:url];
}

@end
