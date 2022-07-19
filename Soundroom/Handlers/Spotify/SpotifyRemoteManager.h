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

@interface SpotifyRemoteManager : NSObject <SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate>

@property (strong, nonatomic) SPTConfiguration *configuration;
@property (strong, nonatomic) SPTSessionManager *sessionManager;
@property (strong, nonatomic) SPTAppRemote *appRemote;
@property (strong, nonatomic) NSString *accessToken;

+ (instancetype)shared;

- (void)authorizeSession;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;
- (BOOL)isConnected;

@end

NS_ASSUME_NONNULL_END
