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

@interface SpotifySessionManager : NSObject <SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate>

@property (strong, nonatomic, readonly) NSString *accessToken;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isSwitchingSong;
@property (strong, nonatomic) NSString *appRemoteTrackURI;

+ (instancetype)shared;

- (void)authorizeSession;
- (void)signOut;
- (BOOL)isSessionAuthorized;

- (void)playTrackWithSpotifyURI:(NSString *)spotifyURI;
- (void)resumePlayback;
- (void)pausePlayback;

- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts;
- (void)sceneWillResignActive;
- (void)sceneDidBecomeActive;

@end

NS_ASSUME_NONNULL_END
