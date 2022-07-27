//
//  AppDelegate.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "AppDelegate.h"
#import "SpotifySessionManager.h"
#import "ParseConstants.h"
#import "Request.h"
#import "Room.h"
#import "Upvote.h"
#import "Downvote.h"
#import "Invitation.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // model configuration
    [Room registerSubclass]; // TODO: remove?
    [Request registerSubclass];
    [Upvote registerSubclass];
    [Downvote registerSubclass];
    [Invitation registerSubclass];
    
    // parse configuration
    ParseClientConfiguration *configuration = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        configuration.applicationId = [dictionary objectForKey:credentialsKeyParseAppId];
        configuration.clientKey = [dictionary objectForKey:credentialsKeyParseClientKey];
        configuration.server = parseConfigurationServerURL;
    }];
    [Parse initializeWithConfiguration:configuration];
    
    // spotify authorization
    [[SpotifySessionManager shared] authorizeSession];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[SpotifySessionManager shared] applicationWillResignActive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[SpotifySessionManager shared] applicationDidBecomeActive];
}

@end
