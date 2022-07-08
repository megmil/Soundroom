//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "SpotifyAPIManager.h"
#import "Song.h"
#import "SpotifyAuthClient.h"

static NSString * const baseURLString = @"https://api.spotify.com";

@implementation SpotifyAPIManager

+ (instancetype)shared {
    static SpotifyAPIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    self = [self initWithBaseURL:baseURL];
    return self;
}

- (void)loadCredentials {
    
    NSDictionary *credentials = [self credentials];
    self.clientId = [credentials objectForKey: @"OAuth2ClientId"];
    self.secret = [credentials objectForKey: @"OAuth2Secret"];
    
    // check for launch arguments override
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"OAuth2ClientId"]) {
        self.clientId = [[NSUserDefaults standardUserDefaults] stringForKey:@"OAuth2ClientId"];
    }
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"OAuth2Secret"]) {
        self.secret = [[NSUserDefaults standardUserDefaults] stringForKey:@"OAuth2Secret"];
    }
}

- (NSDictionary *)credentials {
    NSString *path = [[NSBundle mainBundle] pathForResource: @"OAuth2Credentials" ofType: @"plist"];
    NSDictionary *credentials = [NSDictionary dictionaryWithContentsOfFile:path];
    return credentials;
}

- (BOOL)credentialsLoaded {
    return (self.clientId && self.secret);
}

- (void)getSongsWithQuery:(NSString *)query completion:(void(^)(NSArray *songs, NSError *error))completion {
    
    NSString *urlString = [NSString stringWithFormat:@"v1/search?"];
    
    [[SpotifyAuthClient sharedInstance] accessToken:^(NSString *accessToken) {
        if (accessToken) {
            NSDictionary *parameters = [self searchRequestParametersForToken:accessToken query:query];
            [self getSongsWithURLString:urlString parameters:parameters completion:completion];
        } else {
            NSLog(@"API: Error: Access token is nil.");
        }
    }];
}

- (void)getSongsWithURLString:(NSString *)urlString parameters:(NSDictionary *)parameters
                   completion:(void(^)(NSArray *songs, NSError *error))completion {
    
    [self GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        // TODO: progress
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable dictionary) {
        NSMutableArray *songs = [Song songsWithDictionary:dictionary];
        completion(songs, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

# pragma mark - Helpers

- (NSDictionary *)searchRequestParametersForToken:(NSString *)token query:(NSString *)query {
    
    if ([self credentialsLoaded] == NO) {
        [self loadCredentials];
    }
    
    NSDictionary *parameters = @{@"client_id": self.clientId,
                                 @"client_secret": self.secret,
                                 @"access_token": token,
                                 @"type": @"track",
                                 @"q": query};
    return parameters;
}

@end
