//
//  SceneDelegate.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SceneDelegate.h"
#import "SpotifySessionManager.h"
#import "LoginViewController.h"
#import "ParseUserManager.h"
#import "ParseLiveQueryManager.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    // if there is no current user, show the login view
    if (![ParseUserManager isLoggedIn]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LoginViewController *userLoginVC = [storyboard instantiateViewControllerWithIdentifier:LoginViewControllerIdentifier];
        self.window.rootViewController = userLoginVC;
    } else {
        // else, configure live subscriptions for current user data
        [[ParseLiveQueryManager shared] configureUserLiveSubscriptions];
    }
    
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    [[SpotifySessionManager shared] openURLContexts:URLContexts];
}

- (void)sceneWillResignActive:(UIScene *)scene {
    [[SpotifySessionManager shared] sceneWillResignActive];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    [[SpotifySessionManager shared] sceneDidBecomeActive];
}

@end
