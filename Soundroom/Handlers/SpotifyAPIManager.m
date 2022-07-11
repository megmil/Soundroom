//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "SpotifyAPIManager.h"
#import "Song.h"
#import "SpotifyAuthClient.h"

static NSString * const baseURLString = @"https://api.spotify.com"; // TODO: static?

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
    NSString *urlString = [NSString stringWithFormat:@"v1/search?"];
    
    [self GET:urlString parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
        // TODO: progress
    } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable response) {
        NSMutableArray *songs = [Song songsWithJSONResponse:response];
        completion(songs, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
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
            NSLog(@"API: Error: Access token is nil.");
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

@end
