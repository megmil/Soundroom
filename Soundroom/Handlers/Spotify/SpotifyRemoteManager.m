//
//  SpotifyRemoteManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/18/22.
//

#import "SpotifyRemoteManager.h"
@import STKWebKitViewController;

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
        
        _configuration = [[SPTConfiguration alloc] initWithClientID:clientId redirectURL:redirectURL];
        _configuration.tokenSwapURL = credentials[@"spotify-token-swap-url"];
        _configuration.tokenRefreshURL = credentials[@"spotify-token-refresh-url"];
        _configuration.playURI = nil;
        
        _sessionManager = [[SPTSessionManager alloc] initWithConfiguration:_configuration delegate:self];
        
        _appRemote = [[SPTAppRemote alloc] initWithConfiguration:_configuration logLevel:SPTAppRemoteLogLevelDebug]; // TODO: change from debug
        
    }
    
    return self;
    
}

- (void)authorizeSession {
    [_sessionManager initiateSessionWithScope:SPTAppRemoteControlScope options:SPTDefaultAuthorizationOption];
}

- (void)sessionManager:(nonnull SPTSessionManager *)manager didFailWithError:(nonnull NSError *)error {
    //
}

- (void)sessionManager:(nonnull SPTSessionManager *)manager didInitiateSession:(nonnull SPTSession *)session {
    _appRemote.connectionParameters.accessToken = session.accessToken;
    [_appRemote connect];
}

- (void)retrieveCodeFromUrl:(NSURL *)url withOptions:(UISceneOpenURLOptions *)options {
    if (url) {
        [_sessionManager application:[UIApplication sharedApplication] openURL:url options:[NSMutableDictionary dictionary]];
    }
}

@end
