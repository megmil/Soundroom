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
#import "SpotifyRemoteManager.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    // if there is no current user, show the login view
    if (![PFUser currentUser]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        self.window.rootViewController = userLoginVC;
    }
    
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    [[SpotifyRemoteManager shared] openURLContexts:URLContexts];
}

@end
