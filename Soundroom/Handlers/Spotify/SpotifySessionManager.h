//
//  SpotifyRemoteManager.h
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import <Foundation/Foundation.h>
#import <SpotifyiOS/SpotifyiOS.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const SpotifySessionManagerAuthorizedNotificaton;
extern NSString *const SpotifySessionManagerDeauthorizedNotificaton;
extern NSString *const SpotifySessionManagerRemoteConnectedNotificaton;
extern NSString *const SpotifySessionManagerRemoteDisconnectedNotificaton;

@interface SpotifySessionManager : NSObject <SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate>

@property (strong, nonatomic) SPTConfiguration *configuration;
@property (strong, nonatomic) SPTSessionManager *sessionManager;
@property (strong, nonatomic) SPTAppRemote *appRemote;
@property (strong, nonatomic) NSString *accessToken;

+ (instancetype)shared;

- (void)authorizeSession;
- (void)signOut;
- (void)playSongWithSpotifyURI:(NSString *)spotifyURI;
- (BOOL)isSessionAuthorized;
- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;

@end

NS_ASSUME_NONNULL_END
