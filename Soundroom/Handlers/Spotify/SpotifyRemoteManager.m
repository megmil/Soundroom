//
//  SpotifyRemoteManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import "SpotifyRemoteManager.h"

@implementation SpotifyRemoteManager

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
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
        NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
        NSString *clientId = credentials[@"spotify-client-id"];
        NSString *redirectURLString = credentials[@"spotify-redirect-url"];
        NSURL *redirectURL = [NSURL URLWithString:redirectURLString];
        
        NSString *tokenSwapURLString = credentials[@"spotify-token-swap-url"];
        NSString *tokenRefreshURLString = credentials[@"spotify-token-refresh-url"];
        
        _configuration = [[SPTConfiguration alloc] initWithClientID:clientId redirectURL:redirectURL];
        _configuration.tokenSwapURL = [NSURL URLWithString:tokenSwapURLString];
        _configuration.tokenRefreshURL = [NSURL URLWithString:tokenRefreshURLString];
        _configuration.playURI = @""; // continues playing the most recent song (must be playing song to connect)
        
        _sessionManager = [[SPTSessionManager alloc] initWithConfiguration:_configuration delegate:self];
        
        _appRemote = [[SPTAppRemote alloc] initWithConfiguration:_configuration logLevel:SPTAppRemoteLogLevelDebug]; // TODO: change from debug
        _appRemote.delegate = self;
        
    }
    
    return self;
    
}

# pragma mark - Public

- (void)accessTokenWithCompletion:(void(^)(NSString *accessToken))completion {
    if ([self isAppRemoteConnected]) {
        completion(_appRemote.connectionParameters.accessToken);
    } else {
        completion(nil);
    }
}

- (void)authorizeSession {
    SPTScope requestedScope = SPTAppRemoteControlScope;
    [_sessionManager initiateSessionWithScope:requestedScope options:SPTDefaultAuthorizationOption];
}

- (void)signOut {
    _sessionManager.session = nil;
    [_appRemote disconnect];
}

- (BOOL)isAppRemoteConnected {
    return [_appRemote isConnected];
}

- (void)pausePlayback {
    if (_sessionManager.session) {
        [_appRemote.playerAPI pause:nil];
    }
}


# pragma mark - SPTSessionManagerDelegate

- (void)sessionManager:(nonnull SPTSessionManager *)manager didInitiateSession:(nonnull SPTSession *)session {
    _appRemote.connectionParameters.accessToken = session.accessToken;
    [_appRemote connect];
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
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyRemoteManagerConnectedNotification object:self];
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didDisconnectWithError:(nullable NSError *)error {
    NSLog(@"disconnect: %@", error.localizedDescription);
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyRemoteManagerDisconnectedNotification object:self];
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(nullable NSError *)error {
    NSLog(@"failed connection: %@", error.localizedDescription);
}

# pragma mark - SPTAppRemotePlayerStateDelegate

- (void)playerStateDidChange:(nonnull id<SPTAppRemotePlayerState>)playerState {
    //
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
