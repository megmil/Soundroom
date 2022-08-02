//
//  SpotifyRemoteManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import "SpotifySessionManager.h"
#import "MusicPlayerManager.h"
#import "RoomManager.h"
#import "Track.h"

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

# pragma mark - Authorization

- (void)authorizeSession {
    SPTScope requestedScope = SPTAppRemoteControlScope;
    [_sessionManager initiateSessionWithScope:requestedScope options:SPTDefaultAuthorizationOption];
}

- (void)signOut {
    _sessionManager.session = nil;
    [_appRemote disconnect];
}

# pragma mark - Playback

- (void)playTrackWithStreamingId:(NSString *)spotifyURI {
    
    if (_appRemote.isConnected) {
        [_appRemote.playerAPI play:spotifyURI callback:nil];
        return;
    }
    
    [_appRemote authorizeAndPlayURI:spotifyURI];
    [_appRemote connect];
    
}

- (void)resumePlayback {
    [_appRemote.playerAPI resume:nil];
}

- (void)pausePlayback {
    [_appRemote.playerAPI pause:nil];
}

# pragma mark - SPTSessionManagerDelegate

- (void)sessionManager:(SPTSessionManager *)manager didInitiateSession:(SPTSession *)session {
    _appRemote.connectionParameters.accessToken = session.accessToken;
    [[MusicPlayerManager shared] setAccessToken:session.accessToken];
}

- (void)sessionManager:(SPTSessionManager *)manager didFailWithError:(NSError *)error {
    [[MusicPlayerManager shared] setAccessToken:nil];
}

# pragma mark - SPTAppRemoteDelegate

- (void)appRemoteDidEstablishConnection:(SPTAppRemote *)appRemote {
    
    _appRemote.playerAPI.delegate = self;
    [_appRemote.playerAPI setRepeatMode:SPTAppRemotePlaybackOptionsRepeatModeOff callback:nil];
    [_appRemote.playerAPI subscribeToPlayerState:^(id succeeded, NSError *error) {
        if (succeeded) {
            [self->_appRemote.playerAPI getPlayerState:^(id playerState, NSError *error) {
                if (playerState) {
                    [self handleNewPlayerState:playerState];
                }
            }];
        }
    }];
    
}

- (void)appRemote:(SPTAppRemote *)appRemote didDisconnectWithError:(nullable NSError *)error {
    //
}

- (void)appRemote:(SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(nullable NSError *)error {
    //
}

# pragma mark - SPTAppRemotePlayerStateDelegate

- (void)playerStateDidChange:(id<SPTAppRemotePlayerState>)playerState {
    [self updateMusicPlayerManagerWithPlayerState:playerState];
    [self checkIfCurrentSongEndedWithPlayerState:playerState];
}

# pragma mark - Scene Delegate

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
        [self pausePlayback];
        [_appRemote disconnect];
    }
}

# pragma mark - Helpers

- (void)handleNewPlayerState:(id<SPTAppRemotePlayerState>)playerState {
    [self updateMusicPlayerManagerWithPlayerState:playerState];
    [[MusicPlayerManager shared] validateNewPlayerState];
}

- (void)updateMusicPlayerManagerWithPlayerState:(id<SPTAppRemotePlayerState>)playerState {
    [[MusicPlayerManager shared] setPlaybackTrackId:playerState.track.URI];
    [[MusicPlayerManager shared] setIsPlaying:!playerState.isPaused];
}

- (void)checkIfCurrentSongEndedWithPlayerState:(id<SPTAppRemotePlayerState>)playerState {
    
    BOOL isPlaying = !playerState.isPaused;
    BOOL isSwitchingSong = [[MusicPlayerManager shared] isSwitchingSong];
    NSUInteger remainingSeconds = playerState.playbackPosition / 1000;
    
    // check if current song ended
    if (!isPlaying && remainingSeconds == 0 && !isSwitchingSong) {
        [[MusicPlayerManager shared] didEndCurrentSong];
    }
    
}

@end
