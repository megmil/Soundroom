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
        _configuration.playURI = nil;
        
        _sessionManager = [[SPTSessionManager alloc] initWithConfiguration:_configuration delegate:self];
        
        _appRemote = [[SPTAppRemote alloc] initWithConfiguration:_configuration logLevel:SPTAppRemoteLogLevelDebug]; // TODO: change from debug
        _appRemote.delegate = self;
        
    }
    
    return self;
    
}

- (BOOL)isConnected {
    return [_appRemote isConnected];
}

- (void)authorizeSession {
    [_sessionManager initiateSessionWithScope:SPTAppRemoteControlScope options:SPTDefaultAuthorizationOption];
}

- (void)sessionManager:(nonnull SPTSessionManager *)manager didFailWithError:(nonnull NSError *)error {
    //
}

- (void)sessionManager:(nonnull SPTSessionManager *)manager didInitiateSession:(nonnull SPTSession *)session {
    _appRemote.connectionParameters.accessToken = session.accessToken;
    _accessToken = session.accessToken;
    [_appRemote connect];
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didDisconnectWithError:(nullable NSError *)error {
    //
}

- (void)appRemote:(nonnull SPTAppRemote *)appRemote didFailConnectionAttemptWithError:(nullable NSError *)error {
    //
}

- (void)appRemoteDidEstablishConnection:(nonnull SPTAppRemote *)appRemote {
    _appRemote.playerAPI.delegate = self;
    [_appRemote.playerAPI subscribeToPlayerState:^(id result, NSError *error) {
        if (error) {
            NSLog(@"error: %@", error.localizedDescription);
        }
    }];
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
