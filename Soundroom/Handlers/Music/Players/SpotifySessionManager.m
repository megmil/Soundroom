//
//  SpotifyRemoteManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import "SpotifySessionManager.h"
#import "MusicPlayerManager.h"
#import "RoomManager.h"
#import "ParseUserManager.h"
#import "Track.h"

static NSString *const silentTrackURI = @"spotify:track:7p5bQJB4XsZJEEn6Tb7EaL";
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
    _configuration.playURI = silentTrackURI; // cannot connect to app remote without playing a track
    
}

# pragma mark - Authorization

- (void)authorizeSession {
    [[MusicPlayerManager shared] setAccountType:Spotify];
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
    _appRemote.connectionParameters.accessToken = nil;
    [[MusicPlayerManager shared] setAccessToken:nil];
}

# pragma mark - SPTAppRemoteDelegate

- (void)appRemoteDidEstablishConnection:(SPTAppRemote *)appRemote {
    
    _appRemote.playerAPI.delegate = self;
    
    SPTAppRemotePlaybackOptionsRepeatMode repeatMode = [ParseUserManager isCurrentUserHost] ? SPTAppRemotePlaybackOptionsRepeatModeOff : SPTAppRemotePlaybackOptionsRepeatModeTrack;
    [_appRemote.playerAPI setRepeatMode:repeatMode callback:nil];
    
    [_appRemote.playerAPI subscribeToPlayerState:^(id succeeded, NSError *error) {
        if (succeeded) {
            [self->_appRemote.playerAPI getPlayerState:^(id playerState, NSError *error) {
                if (playerState) {
                    [self updateMusicPlayerManagerWithPlayerState:playerState];
                    [self validateCurrentTrackWithPlayerState:playerState];
                }
            }];
        }
    }];
    
}

- (void)appRemote:(SPTAppRemote *)appRemote didDisconnectWithError:(NSError *)error {
    [[MusicPlayerManager shared] didDisconnectRemote];
}

- (void)appRemote:(SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(NSError *)error {
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
        [[MusicPlayerManager shared] pausePlayback];
        [_appRemote disconnect];
    }
}

# pragma mark - Helpers

- (void)updateMusicPlayerManagerWithPlayerState:(id<SPTAppRemotePlayerState>)playerState {
    NSString *streamingId = playerState.track.URI;
    BOOL isPlaying = !playerState.isPaused;
    [[MusicPlayerManager shared] setPlayerTrackId:streamingId];
    [[MusicPlayerManager shared] setIsPlaying:isPlaying];
}

- (void)checkIfCurrentSongEndedWithPlayerState:(id<SPTAppRemotePlayerState>)playerState {
    
    BOOL isPlaying = !playerState.isPaused;
    NSInteger playbackPosition = playerState.playbackPosition; // position of playback in ms
    
    // check if current song ended
    if (playbackPosition == 0 && !isPlaying) {
        [[MusicPlayerManager shared] didEndCurrentSong];
    }
    
}

- (void)validateCurrentTrackWithPlayerState:(id<SPTAppRemotePlayerState>)playerState {
    
    NSString *roomTrackId = [[RoomManager shared] currentTrackStreamingId];
    NSString *playerTrackId = playerState.track.URI;
    BOOL isPlaying = !playerState.isPaused;
    
    // check if music player is playing the wrong song
    if (isPlaying && ![roomTrackId isEqualToString:playerTrackId]) {
        [self pausePlayback];
        return;
    }
    
    if (!isPlaying && roomTrackId != nil) {
        [[MusicPlayerManager shared] resumePlayback];
    }
    
}

@end
