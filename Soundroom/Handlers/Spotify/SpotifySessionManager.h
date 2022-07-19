//
//  SpotifyRemoteManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import <Foundation/Foundation.h>
#import "SpotifyiOS/SpotifyiOS.h"

#define SpotifySessionManagerAuthorizedNotificaton @"SpotifySessionManagerAuthorizedNotificaton"
#define SpotifySessionManagerDeauthorizedNotificaton @"SpotifySessionManagerDeauthorizedNotificaton"
#define SpotifySessionManagerRemoteConnectedNotificaton @"SpotifySessionManagerRemoteConnectedNotificaton"
#define SpotifySessionManagerRemoteDisconnectedNotificaton @"SpotifySessionManagerRemoteDisconnectedNotificaton" // TODO: remove?

NS_ASSUME_NONNULL_BEGIN

@interface SpotifySessionManager : NSObject <SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate>

@property (strong, nonatomic) SPTConfiguration *configuration;
@property (strong, nonatomic) SPTSessionManager *sessionManager;
@property (strong, nonatomic) SPTAppRemote *appRemote;
@property (strong, nonatomic) NSString *accessToken;

+ (instancetype)shared;

- (void)authorizeSession;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;
- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)signOut;
- (void)playSongWithSpotifyURI:(NSString *)spotifyURI;
- (BOOL)isSessionAuthorized;

@end

NS_ASSUME_NONNULL_END
