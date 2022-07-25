//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "SpotifyAPIManager.h"
#import "SpotifySessionManager.h"
#import "ParseQueryManager.h"

static NSString * const baseURLString = @"https://api.spotify.com";

@implementation SpotifyAPIManager

+ (instancetype)shared {
    static SpotifyAPIManager *sharedManager;
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

# pragma mark - Server

- (void)getSongsWithParameters:(NSDictionary *)parameters
                    completion:(void(^)(NSArray *songs, NSError *error))completion {
    [self GET:@"v1/search?" parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *songs = [Track songsWithJSONResponse:responseObject];
        completion(songs, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

- (void)getSongWithSpotifyId:(NSString *)spotifyId parameters:(NSDictionary *)parameters completion:(void(^)(Track *song, NSError *error))completion {
    
    NSString *urlString = [NSString stringWithFormat:@"v1/tracks/%@", spotifyId];
    
    [self GET:urlString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        Track *song = [Track songWithJSONResponse:responseObject];
        completion(song, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

# pragma mark - Public

- (void)getSongsWithQuery:(NSString *)query completion:(void(^)(NSArray *songs, NSError *error))completion {
    NSString *accessToken = [[SpotifySessionManager shared] accessToken]; // nil if current session is nil
    if (accessToken) {
        NSDictionary *parameters = [self searchRequestParametersWithToken:accessToken query:query];
        [self getSongsWithParameters:parameters completion:completion];
    }  else {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
    }
}

- (void)getSongWithSpotifyId:(NSString *)spotifyId completion:(void(^)(Track *song, NSError *error))completion {
    NSString *accessToken = [[SpotifySessionManager shared] accessToken]; // nil if current session is nil
    if (accessToken) {
        NSDictionary *parameters = [self getRequestParametersWithToken:accessToken];
        [self getSongWithSpotifyId:spotifyId parameters:parameters completion:completion];
    } else {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
    }
}

# pragma mark - Helpers

- (void)postFailedAuthorizationNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:SpotifyAPIManagerFailedAccessTokenNotification object:self];
}

- (NSDictionary *)searchRequestParametersWithToken:(NSString *)token query:(NSString *)query {
    NSDictionary *parameters = @{@"access_token": token,
                                 @"type": @"track",
                                 @"q": query};
    return parameters;
}

- (NSDictionary *)getRequestParametersWithToken:(NSString *)token {
    NSDictionary *parameters = @{@"access_token": token};
    return parameters;
}

@end
