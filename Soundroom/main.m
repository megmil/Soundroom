//
//  main.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SpotifyAPIManager.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    
    [[SpotifyAPIManager shared] getSongsWithText:@"reckoner" forFilter:@"track" completion:nil];
    
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
