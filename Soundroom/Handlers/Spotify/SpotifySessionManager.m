//
//  SpotifyRemoteManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import "SpotifySessionManager.h"

NSString *const SpotifySessionManagerAuthorizedNotificaton = @"SpotifySessionManagerAuthorizedNotificaton";
NSString *const SpotifySessionManagerDeauthorizedNotificaton = @"SpotifySessionManagerDeauthorizedNotificaton";
NSString *const SpotifySessionManagerRemoteConnectedNotificaton = @"SpotifySessionManagerRemoteConnectedNotificaton";
NSString *const SpotifySessionManagerRemoteDisconnectedNotificaton = @"SpotifySessionManagerRemoteDisconnectedNotificaton";

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
        
        _sessionManager = [[SPTSessionManager alloc] initWithConfiguration:_configuration delegate:self];
        
        _appRemote = [[SPTAppRemote alloc] initWithConfiguration:_configuration logLevel:SPTAppRemoteLogLevelDebug]; // TODO: change from debug
        _appRemote.delegate = self;
        
    }
    
    return self;
    
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

- (void)playSongWithSpotifyURI:(NSString *)spotifyURI {
    if (_appRemote.isConnected) {
        [_appRemote.playerAPI play:spotifyURI callback:nil];
        return;
    }
    [_appRemote authorizeAndPlayURI:spotifyURI];
    [_appRemote connect];
}

# pragma mark - SPTSessionManagerDelegate

- (void)sessionManager:(nonnull SPTSessionManager *)manager didInitiateSession:(nonnull SPTSession *)session {
    _appRemote.connectionParameters.accessToken = session.accessToken;
    _accessToken = session.accessToken;
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifySessionManagerAuthorizedNotificaton object:self];
}

- (void)sessionManager:(nonnull SPTSessionManager *)manager didFailWithError:(nonnull NSError *)error {
    NSLog(@"fail: %@", error.localizedDescription);
}

# pragma mark - SPTAppRemoteDelegate

- (void)appRemoteDidEstablishConnection:(nonnull SPTAppRemote *)appRemote {
    _appRemote.playerAPI.delegate = self;
    [_appRemote.playerAPI subscribeToPlayerState:^(id result, NSError *error) {
        if (error) {
            NSLog(@"subscription error: %@", error.localizedDescription);
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifySessionManagerRemoteConnectedNotificaton object:self];
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didDisconnectWithError:(nullable NSError *)error {
    NSLog(@"disconnect: %@", error.localizedDescription);
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(nullable NSError *)error {
    NSLog(@"failed connection: %@", error.localizedDescription);
}

# pragma mark - SPTAppRemotePlayerStateDelegate

- (void)playerStateDidChange:(nonnull id<SPTAppRemotePlayerState>)playerState {
    NSLog(@"%ld", playerState.playbackPosition);
}

# pragma mark - SceneDelegate

- (void)openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *url = URLContexts.allObjects.firstObject.URL;
    [_sessionManager application:[UIApplication sharedApplication] openURL:url options:[NSMutableDictionary dictionary]];
}

- (void)applicationDidBecomeActive {
    if (_appRemote.connectionParameters.accessToken) {
        [_appRemote connect];
    }
}

- (void)applicationWillResignActive {
    if (_appRemote.isConnected) {
        [_appRemote disconnect];
    }
}

@end
