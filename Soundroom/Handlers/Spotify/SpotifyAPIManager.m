//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/6/22.
//

#import "SpotifyAPIManager.h"
#import "SpotifySessionManager.h"

NSString *const SpotifyAPIManagerFailedAccessTokenNotification = @"SpotifyAPIManagerFailedAccessTokenNotification";

static NSString *const baseURLString = @"https://api.spotify.com";
static NSString *const searchURLString = @"v1/search?";
static NSString *const getTrackURLString = @"v1/tracks/";

static NSString *const tokenParameterName = @"access_token";
static NSString *const typeParameterName = @"type";
static NSString *const queryParameterName = @"q";

static NSString *const trackTypeName = @"track";

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

- (void)getTracksWithParameters:(NSDictionary *)parameters
                     completion:(void(^)(NSArray *tracks, NSError *error))completion {
    [self GET:searchURLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *tracks = [Track tracksWithJSONResponse:responseObject];
        completion(tracks, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

- (void)getTrackWithSpotifyId:(NSString *)spotifyId parameters:(NSDictionary *)parameters completion:(void(^)(Track *track, NSError *error))completion {
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@", getTrackURLString, spotifyId];
    
    [self GET:urlString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        Track *track = [Track trackWithJSONResponse:responseObject];
        completion(track, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
}

# pragma mark - Public

- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion {
    NSString *accessToken = [[SpotifySessionManager shared] accessToken]; // nil if current session is nil
    if (accessToken) {
        NSDictionary *parameters = [self searchRequestParametersWithToken:accessToken query:query];
        [self getTracksWithParameters:parameters completion:completion];
    }  else {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
    }
}

- (void)getTrackWithSpotifyId:(NSString *)spotifyId completion:(void(^)(Track *track, NSError *error))completion {
    NSString *accessToken = [[SpotifySessionManager shared] accessToken]; // nil if current session is nil
    if (accessToken) {
        NSDictionary *parameters = [self getRequestParametersWithToken:accessToken];
        [self getTrackWithSpotifyId:spotifyId parameters:parameters completion:completion];
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
    NSDictionary *parameters = @{tokenParameterName:token,
                                 typeParameterName:trackTypeName,
                                 queryParameterName:query};
    return parameters;
}

- (NSDictionary *)getRequestParametersWithToken:(NSString *)token {
    NSDictionary *parameters = @{tokenParameterName:token};
    return parameters;
}

@end
