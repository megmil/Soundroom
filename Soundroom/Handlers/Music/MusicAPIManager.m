//
//  MusicAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "MusicAPIManager.h"
#import "Track.h"

NSString *const MusicAPIManagerFailedAccessTokenNotification = @"MusicAPIManagerFailedAccessTokenNotification";

@implementation MusicAPIManager

+ (instancetype)shared {
    static MusicAPIManager *sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    NSString *baseURLString = [_musicCatalog baseURLString];
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    self = [self initWithBaseURL:baseURL];
    return self;
}

# pragma mark - Server

- (void)getTracksWithParameters:(NSDictionary *)parameters
                     completion:(void(^)(NSArray *tracks, NSError *error))completion {
    
    NSString *searchURLString = [_musicCatalog searchURLString];
    
    [self GET:searchURLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *tracks = [Track tracksWithJSONResponse:responseObject];
        completion(tracks, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
    
}

- (void)getTrackWithStreamingId:(NSString *)streamingId parameters:(NSDictionary *)parameters completion:(void(^)(Track *track, NSError *error))completion {
    
    NSString *getTrackURLString = [_musicCatalog getTrackURLString];
    NSString *urlString = [NSString stringWithFormat:getTrackURLString, streamingId];
    
    [self GET:urlString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        Track *track = [Track trackWithJSONResponse:responseObject];
        completion(track, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
    
}

# pragma mark - Public

- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion {
    NSString *accessToken = [_musicCatalog accessToken]; // nil if current session is nil
    if (accessToken) {
        NSDictionary *parameters = [self searchRequestParametersWithToken:accessToken query:query];
        [self getTracksWithParameters:parameters completion:completion];
    } else {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
    }
}

- (void)getTrackWithStreamingId:(NSString *)streamingId completion:(void(^)(Track *track, NSError *error))completion {
    NSString *accessToken = [_musicCatalog accessToken]; // nil if current session is nil
    if (accessToken) {
        NSDictionary *parameters = [self getRequestParametersWithToken:accessToken];
        [self getTrackWithStreamingId:streamingId parameters:parameters completion:completion];
    } else {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
    }
}

# pragma mark - Helpers

- (void)postFailedAuthorizationNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicAPIManagerFailedAccessTokenNotification object:self];
}

- (NSDictionary *)searchRequestParametersWithToken:(NSString *)token query:(NSString *)query {
    
    NSString *tokenParameterName = [_musicCatalog tokenParameterName];
    NSString *typeParameterName = [_musicCatalog typeParameterName];
    NSString *trackTypeName = [_musicCatalog trackTypeName];
    NSString *queryParameterName = [_musicCatalog queryParameterName];
    
    NSDictionary *parameters = @{tokenParameterName:token,
                                 typeParameterName:trackTypeName,
                                 queryParameterName:query};
    return parameters;
}

- (NSDictionary *)getRequestParametersWithToken:(NSString *)token {
    NSString *tokenParameterName = [_musicCatalog tokenParameterName];
    NSDictionary *parameters = @{tokenParameterName:token};
    return parameters;
}

@end
