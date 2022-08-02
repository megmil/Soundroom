//
//  AppDelegate.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "AppDelegate.h"
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
    [Room registerSubclass];
    [Request registerSubclass];
    [Upvote registerSubclass];
    [Downvote registerSubclass];
    [Invitation registerSubclass];
    
    // parse configuration
    ParseClientConfiguration *configuration = [ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:path];
        configuration.applicationId = [dictionary objectForKey:credentialsKeyParseApplicationId];
        configuration.clientKey = [dictionary objectForKey:credentialsKeyParseClientKey];
        configuration.server = parseConfigurationServerURL;
    }];
    [Parse initializeWithConfiguration:configuration];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
