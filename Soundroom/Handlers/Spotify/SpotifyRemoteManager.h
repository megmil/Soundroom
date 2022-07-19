//
//  SpotifyRemoteManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import <Foundation/Foundation.h>
#import "SpotifyiOS/SpotifyiOS.h"

#define SpotifyRemoteManagerConnectedNotification @"SpotifyRemoteManagerConnectedNotification"
#define SpotifyRemoteManagerDisconnectedNotification @"SpotifyRemoteManagerDisconnectedNotification"

NS_ASSUME_NONNULL_BEGIN

@interface SpotifyRemoteManager : NSObject <SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate>

@property (strong, nonatomic) SPTConfiguration *configuration;
@property (strong, nonatomic) SPTSessionManager *sessionManager;
@property (strong, nonatomic) SPTAppRemote *appRemote;

+ (instancetype)shared;

- (void)authorizeSession;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;
- (BOOL)isAppRemoteConnected;
- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)pausePlayback;
- (void)signOut;
- (void)accessTokenWithCompletion:(void(^)(NSString * _Nullable accessToken))completion;

@end

NS_ASSUME_NONNULL_END
