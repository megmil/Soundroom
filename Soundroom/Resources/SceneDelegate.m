//
//  SceneDelegate.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SceneDelegate.h"
#import "SpotifyAuthClient.h"
#import "Realm/Realm.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    
    /*
    if ([[SpotifyAuthClient shared] signedIn]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        self.window.rootViewController = tabBarController;
    }
     */
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.allObjects.firstObject.URL;
    [[SpotifyAuthClient shared] retrieveCodeFromUrl:url];
}

@end
