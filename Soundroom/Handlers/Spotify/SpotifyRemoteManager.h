//
//  SpotifyRemoteManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import <Foundation/Foundation.h>
#import "SpotifyiOS/SpotifyiOS.h"

#define kOAuth2SignedInNotification @"OAuth2SignedInNotification"

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyRemoteManager : NSObject <SPTSessionManagerDelegate, SPTAppRemoteDelegate>

@property (strong, nonatomic) SPTConfiguration *configuration;
@property (strong, nonatomic) SPTSessionManager *sessionManager;
@property (strong, nonatomic) SPTAppRemote *appRemote;

+ (instancetype)shared;

- (void)authorizeSession;
- (void)retrieveCodeFromUrl:(NSURL *)url withOptions:(UISceneOpenURLOptions *)options;

@end

NS_ASSUME_NONNULL_END
