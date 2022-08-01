//
//  SpotifyRemoteManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import "SpotifySessionManager.h"
#import "RoomManager.h"
#import "Track.h"
#import <Parse/Parse.h>

NSString *const SpotifySessionManagerAuthorizedNotificaton = @"SpotifySessionManagerAuthorizedNotificaton";
NSString *const SpotifySessionManagerDeauthorizedNotificaton = @"SpotifySessionManagerDeauthorizedNotificaton";

static NSString *const credentialsKeySpotifyClientId = @"spotify-client-id";
static NSString *const credentialsKeySpotifyRedirectURL = @"spotify-redirect-url";
static NSString *const credentialsKeySpotifyTokenSwapURL = @"spotify-token-swap-url";
static NSString *const credentialsKeySpotifyTokenRefreshURL = @"spotify-token-refresh-url";

@implementation SpotifySessionManager {
    SPTConfiguration *_configuration;
    SPTSessionManager *_sessionManager;
    SPTAppRemote *_appRemote;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (instancetype)init {
    
    self = [super init];
    
    if (self) {
        
        [self setupConfiguration];
        _sessionManager = [[SPTSessionManager alloc] initWithConfiguration:_configuration delegate:self];
        _appRemote = [[SPTAppRemote alloc] initWithConfiguration:_configuration logLevel:SPTAppRemoteLogLevelNone];
        _appRemote.delegate = self;
        
    }
    
    return self;
    
}

- (void)setupConfiguration {
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"]; // TODO: file scope?
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    
    NSString *clientId = credentials[credentialsKeySpotifyClientId];
    NSString *redirectURLString = credentials[credentialsKeySpotifyRedirectURL];
    NSString *tokenSwapURLString = credentials[credentialsKeySpotifyTokenSwapURL];
    NSString *tokenRefreshURLString = credentials[credentialsKeySpotifyTokenRefreshURL];
    
    NSURL *redirectURL = [NSURL URLWithString:redirectURLString];
    NSURL *tokenSwapURL = [NSURL URLWithString:tokenSwapURLString];
    NSURL *tokenRefreshURL = [NSURL URLWithString:tokenRefreshURLString];
    
    _configuration = [[SPTConfiguration alloc] initWithClientID:clientId redirectURL:redirectURL];
    _configuration.tokenSwapURL = tokenSwapURL;
    _configuration.tokenRefreshURL = tokenRefreshURL;
    _configuration.playURI = nil; // continues playing the most recent track (must be playing track to connect)
    
}

# pragma mark - Session Manager

- (void)authorizeSession {
    if ([self isSessionAuthorized]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SpotifySessionManagerAuthorizedNotificaton object:self];
        return;
    }
    SPTScope requestedScope = SPTAppRemoteControlScope;
    [_sessionManager initiateSessionWithScope:requestedScope options:SPTDefaultAuthorizationOption];
}

- (void)signOut {
    _sessionManager.session = nil;
    [_appRemote disconnect];
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifySessionManagerDeauthorizedNotificaton object:self];
}

- (BOOL)isSessionAuthorized {
    return _sessionManager.session.accessToken;
}

# pragma mark - App Remote

- (void)playTrackWithSpotifyURI:(NSString *)spotifyURI {
    
    if (_appRemote.isConnected) {
        [_appRemote.playerAPI play:spotifyURI callback:nil];
        return;
    }
    
    [_appRemote authorizeAndPlayURI:spotifyURI];
    [_appRemote connect];
    
}

- (void)resumePlayback {
    
    if (_isPlaying) {
        return;
    }
    
    NSString *roomTrackURI = [[RoomManager shared] currentTrackSpotifyURI];
    if (roomTrackURI && [_appRemoteTrackURI isEqualToString:roomTrackURI]) {
        [_appRemote.playerAPI resume:nil];
        return;
    }
    
    if (!_appRemoteTrackURI) {
        [_appRemote.playerAPI play:roomTrackURI callback:nil];
    }
    
    [[RoomManager shared] playTopSong];
    
}

- (void)pausePlayback {
    if (_isPlaying) {
        [_appRemote.playerAPI pause:nil];
        return;
    }
}

# pragma mark - SPTSessionManagerDelegate

- (void)sessionManager:(nonnull SPTSessionManager *)manager didInitiateSession:(nonnull SPTSession *)session {
    _appRemote.connectionParameters.accessToken = session.accessToken;
    _accessToken = session.accessToken;
    [NSNotificationCenter.defaultCenter postNotificationName:SpotifySessionManagerAuthorizedNotificaton object:self];
}

- (void)sessionManager:(nonnull SPTSessionManager *)manager didFailWithError:(nonnull NSError *)error {
}

# pragma mark - SPTAppRemoteDelegate

- (void)appRemoteDidEstablishConnection:(nonnull SPTAppRemote *)appRemote {
    
    _appRemote.playerAPI.delegate = self;
    [_appRemote.playerAPI setRepeatMode:SPTAppRemotePlaybackOptionsRepeatModeOff callback:nil];
    [_appRemote.playerAPI subscribeToPlayerState:^(id succeeded, NSError *error) {
        if (succeeded) {
            [self->_appRemote.playerAPI getPlayerState:^(id result, NSError *error) {
                if (result) {
                    [self validatePlayerState:result];
                }
            }];
        }
    }];
    
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didDisconnectWithError:(nullable NSError *)error {
    //
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(nullable NSError *)error {
    //
}

# pragma mark - SPTAppRemotePlayerStateDelegate

- (void)playerStateDidChange:(nonnull id<SPTAppRemotePlayerState>)playerState {
    
    _appRemoteTrackURI = playerState.track.URI;
    self.isPlaying = !playerState.isPaused;
    
    // check if current song ended
    NSUInteger remainingSeconds = playerState.playbackPosition / 1000;
    if (!_isPlaying && remainingSeconds == 0 && !_isSwitchingSong) {
        [self pausePlayback]; // TODO: confirm app remote is not connected for non-playing members
        [[RoomManager shared] playTopSong];
        return;
    }
    
}

# pragma mark - SceneDelegate

- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.allObjects.firstObject.URL;
    [_sessionManager application:UIApplication.sharedApplication openURL:url options:NSMutableDictionary.dictionary];
}

- (void)sceneDidBecomeActive {
    if (_appRemote.connectionParameters.accessToken) {
        [_appRemote connect];
    }
}

- (void)sceneWillResignActive {
    if (_appRemote.isConnected) {
        [_appRemote.playerAPI pause:nil];
        [_appRemote disconnect];
    }
}

# pragma mark - Setters

- (void)setIsPlaying:(BOOL)isPlaying {
    
    if (_isPlaying == isPlaying) {
        return;
    }
    
    _isPlaying = isPlaying;
    [[RoomManager shared] updatePlayerWithPlayState:_isPlaying];
    
}

- (void)validatePlayerState:(nonnull id<SPTAppRemotePlayerState>)playerState {
    
    _appRemoteTrackURI = playerState.track.URI;
    self.isPlaying = !playerState.isPaused;
    
    // check if app remote is playing the wrong song
    NSString *roomTrackURI = [[RoomManager shared] currentTrackSpotifyURI];
    if (_isPlaying && ![_appRemoteTrackURI isEqualToString:roomTrackURI]) {
        [[RoomManager shared] stopPlayback];
        [self pausePlayback];
        return;
    }
    
    if (!_isPlaying && roomTrackURI) {
        [self resumePlayback];
    }
    
}

@end
