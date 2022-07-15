//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "SpotifyAPIManager.h"
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

# pragma mark - Server

- (void)getSongsWithParameters:(NSDictionary *)parameters
                    completion:(void(^)(NSArray *songs, NSError *error))completion {
    [self GET:@"v1/search?" parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
        NSMutableArray *songs = [Song songsWithJSONResponse:response];
        completion(songs, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

- (void)getSongWithParameters:(NSDictionary *)parameters completion:(void(^)(Song *song, NSError *error))completion {
    [self GET:@"v1/tracks" parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        Song *song = [Song songWithJSONResponse:responseObject];
        completion(song, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

# pragma mark - Public

- (void)getSongsWithQuery:(NSString *)query completion:(void(^)(NSArray *songs, NSError *error))completion {
    [[SpotifyAuthClient shared] accessToken:^(NSString *accessToken) {
        if (accessToken) {
            NSDictionary *parameters = [self searchRequestParametersWithToken:accessToken query:query];
            [self getSongsWithParameters:parameters completion:completion];
        } else {
            completion(nil, nil);
        }
    }];
}

- (void)getSongWithSpotifyId:(NSString *)spotifyId completion:(void(^)(Song *song, NSError *error))completion {
    [[SpotifyAuthClient shared] accessToken:^(NSString *accessToken) {
        if (accessToken) {
            NSDictionary *parameters = [self getRequestParametersWithToken:accessToken spotifyId:spotifyId];
            [self getSongWithParameters:parameters completion:completion];
        } else {
            completion(nil, nil);
        }
    }];
}

# pragma mark - Helpers

- (NSDictionary *)searchRequestParametersWithToken:(NSString *)token query:(NSString *)query {
    NSDictionary *parameters = @{@"access_token": token,
                                 @"type": @"track",
                                 @"q": query};
    return parameters;
}

- (NSDictionary *)getRequestParametersWithToken:(NSString *)token spotifyId:(NSString *)spotifyId {
    NSDictionary *parameters = @{@"access_token": token,
                                 @"id": spotifyId};
    return parameters;
}

@end
