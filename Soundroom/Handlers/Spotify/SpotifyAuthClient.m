//
//  OAuth2Client.m
//  OAuth2-ObjC
//
//  Created by Tom Gallagher on 27/04/2016.
//  Copyright © 2016 Tom Gallagher. All rights reserved.
//

#import "SpotifyAuthClient.h"
#import "AFHTTPSessionManager.h"

@implementation SpotifyAuthClient

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)loadCredentials {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    self.authUrl = [NSURL URLWithString:credentials[@"spotify-auth-url"]];
    self.tokenUrl = [NSURL URLWithString:credentials[@"spotify-token-url"]];
    self.clientId = credentials[@"spotify-client-id"];
    self.secret = credentials[@"spotify-secret"];
    self.scope = credentials[@"spotify-scope"];
    self.redirectUri = [NSURL URLWithString:credentials[@"redirect-uri"]];
    self.scheme = [self.redirectUri scheme];
    credentialsLoaded = YES;
}

- (void)authenticateInViewController:(UIViewController *)viewController {
    if (credentialsLoaded == NO) {
        [self loadCredentials];
    }
    
    if (credentialsLoaded) {
        authViewController = [[STKWebKitModalViewController alloc] initWithURL:[self authUrlWithParameters]];
        authViewController.webKitViewController.customSchemes = @[ self.scheme ];
        [viewController presentViewController:authViewController animated:YES completion:nil];
    }
}

- (void)retrieveCodeFromUrl:(NSURL *)url {
    if ([url.scheme isEqualToString:self.scheme]) {
        NSURLComponents *urlComponents = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSArray *urlQueryItems = [urlComponents queryItems];
        
        if (urlQueryItems.count > 0) {
            for (NSURLQueryItem *urlQueryItem in urlQueryItems) {
                if ([urlQueryItem.name isEqualToString:@"code"]) {
                    __weak __typeof__(STKWebKitModalViewController *)weakAuthViewController = authViewController;
                    [self requestAccessTokenFor:urlQueryItem.value callback:^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:kOAuth2SignedInNotification
                                                                            object:self];
                        [weakAuthViewController dismissViewControllerAnimated:YES completion:nil];
                    }];
                }
            }
        }
    }
}

- (void)persistTokensFromResponse:(id)response callback:(void (^)(void))callback {
    // Access token
    if ([response objectForKey:@"access_token"]) {
        [[NSUserDefaults standardUserDefaults] setObject:response[@"access_token"] forKey:@"OAuth2AccessToken"];
    }

    // Refresh token
    if ([response objectForKey:@"refresh_token"]) {
        [[NSUserDefaults standardUserDefaults] setObject:response[@"refresh_token"] forKey:@"OAuth2RefreshToken"];
    }

    // Access token expires at
    if ([response objectForKey:@"expires_in"]) {
        NSDate *tokenExpiresAt = [self calculateTokenExpiresAtWithResponse:response];
        [[NSUserDefaults standardUserDefaults] setObject:tokenExpiresAt forKey:@"OAuth2TokenExpiresAt"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    callback();
}

#pragma mark - Server

- (void)requestAccessTokenFor:(NSString *)code callback:(void (^)(void))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *parameters = [self tokenRequestParametersForCode:code];
    
    [manager POST:[self.tokenUrl absoluteString] parameters:parameters progress:nil
          success:^(NSURLSessionTask *task, id responseObject) {
        [self persistTokensFromResponse:(id)responseObject callback:^{
            callback();
        }];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        callback();
    }];
}

- (void)requestAccessTokenWithRefreshToken:(NSString *)refreshToken callback:(void (^)(void))callback {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *parameters = [self tokenRequestParametersForRefreshToken:refreshToken];
    
    [manager POST:[self.tokenUrl absoluteString] parameters:parameters progress:nil
          success:^(NSURLSessionTask *task, id responseObject) {
        [self persistTokensFromResponse:(id)responseObject callback:^{
            callback();
        }];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        callback();
    }];
}

#pragma mark Public

- (NSString *)persistedAccessToken {
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"OAuth2AccessToken"];
    return accessToken;
}

- (BOOL)accessTokenExists {
    NSString *accessToken = [self persistedAccessToken];
    BOOL accessTokenExists = accessToken != nil;
    return accessTokenExists;
}

- (NSString *)persistedRefreshToken {
    NSString *refreshToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"OAuth2RefreshToken"];
    return refreshToken;
}

- (BOOL)refreshTokenExists {
    NSString *refreshToken = [self persistedRefreshToken];
    BOOL refreshTokenExists = refreshToken != nil;
    return refreshTokenExists;
}

- (BOOL)accessTokenExpired {
    NSDate *accessTokenExpiresAt = [[NSUserDefaults standardUserDefaults] objectForKey:@"OAuth2TokenExpiresAt"];
    NSDate *now = [NSDate date];
    NSDate *laterDate = [now laterDate:accessTokenExpiresAt];
    BOOL accessTokenExpired = laterDate == now;
    return accessTokenExpired;
}

- (BOOL)signedIn {
    BOOL signedIn = [self accessTokenExists];
    return signedIn;
}

- (void)signOut {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAuth2AccessToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAuth2RefreshToken"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"OAuth2TokenExpiresAt"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOAuth2SignedOutNotification object:self];
}

- (void)accessToken:(void (^)(NSString *accessToken))callback {
    BOOL signedIn = [self signedIn];
    
    if (signedIn) {
        BOOL accessTokenExpired = [self accessTokenExpired];
        
        if (accessTokenExpired) {
            BOOL refreshTokenExists = [self refreshTokenExists];
            
            if (refreshTokenExists) {
                NSString *refreshToken = [self persistedRefreshToken];

                __weak __typeof__(self) weakSelf = self;
                [self requestAccessTokenWithRefreshToken:refreshToken callback:^{
                    BOOL accessTokenExpired = [weakSelf accessTokenExpired];
                    
                    if (accessTokenExpired) {
                        callback(nil);
                    } else {
                        NSString *accessToken = [weakSelf persistedAccessToken];
                        callback(accessToken);
                    }

                }];
            } else {
                callback(nil);
            }
        } else {
            NSString *accessToken = [self persistedAccessToken];
            callback(accessToken);
        }
    } else {
        callback(nil);
    }
}

#pragma mark Helpers

- (NSURL *)authUrlWithParameters {
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.authUrl resolvingAgainstBaseURL:NO];
    NSURLQueryItem *type = [NSURLQueryItem queryItemWithName:@"type" value:@"web_server"];
    NSURLQueryItem *responseType = [NSURLQueryItem queryItemWithName:@"response_type" value:@"code"];
    NSURLQueryItem *display = [NSURLQueryItem queryItemWithName:@"display" value:@"touch"];
    NSURLQueryItem *clientId = [NSURLQueryItem queryItemWithName:@"client_id" value:self.clientId];
    NSURLQueryItem *scope = [NSURLQueryItem queryItemWithName:@"scope" value:self.scope];
    NSURLQueryItem *redirectUri = [NSURLQueryItem queryItemWithName:@"redirect_uri"
                                                              value:[self.redirectUri absoluteString]];
    components.queryItems = @[type, responseType, display, clientId, scope, redirectUri];
    NSURL *url = components.URL;
    return url;
}

- (NSDictionary *)tokenRequestParametersForCode:(NSString *)code {
    if (credentialsLoaded == NO) {
        [self loadCredentials];
    }
    
    NSDictionary *parameters = @{@"client_id": self.clientId,
                                 @"client_secret": self.secret,
                                 @"scope": self.scope,
                                 @"grant_type": @"authorization_code",
                                 @"code": code,
                                 @"redirect_uri": self.redirectUri};
    return parameters;
}

- (NSDictionary *)tokenRequestParametersForRefreshToken:(NSString *)refreshToken {
    if (credentialsLoaded == NO) {
        [self loadCredentials];
    }
    
    NSDictionary *parameters = @{@"client_id": self.clientId,
                                 @"client_secret": self.secret,
                                 @"grant_type": @"refresh_token",
                                 @"refresh_token": refreshToken,
                                 @"redirect_uri": self.redirectUri};
    return parameters;
}

- (NSDate *)calculateTokenExpiresAtWithResponse:(id)response {
    NSDate *now = [NSDate now];
    NSTimeInterval expiresInInterval = (NSTimeInterval)[[response valueForKey:@"expires_in"] intValue];
    NSDate *tokenExpiresAt = [now dateByAddingTimeInterval:expiresInInterval];
    return tokenExpiresAt;
}

@end
