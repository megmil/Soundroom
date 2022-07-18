//
//  AppDelegate.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "SpotifyAuthClient.h"
#import "LoginViewController.h"
#import "QueueSong.h"
#import "Room.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [QueueSong registerSubclass];
    [Room registerSubclass];
    
    ParseClientConfiguration *configuration = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        configuration.applicationId = [dictionary objectForKey:@"parse-app-id"];
        configuration.clientKey = [dictionary objectForKey:@"parse-client-key"];
        configuration.server = @"https://parseapi.back4app.com";
    }];

    [Parse initializeWithConfiguration:configuration];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
