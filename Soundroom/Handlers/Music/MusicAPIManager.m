//
//  MusicAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "MusicAPIManager.h"
#import "MusicPlayerManager.h"
#import "SpotifyCatalog.h"
#import "AppleMusicCatalog.h"
#import "Track.h"
#import "Request.h"

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

// TODO: remove?
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

- (void)getTrackWithUPC:(NSString *)upc parameters:(NSDictionary *)parameters completion:(void(^)(Track *track, NSError *error))completion {
    
    NSString *lookupURLString = [_musicCatalog lookupTrackURLStringWithUPC:upc];
    
    [self GET:lookupURLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        Track *track = [Track trackWithJSONResponse:responseObject];
        completion(track, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
    
}

# pragma mark - Public

- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion {
    
    NSString *accessToken = [self validateMusicCatalog]; // nil if MusicPlayerManager has not authorized correctly
    
    if (accessToken) {
        NSDictionary *parameters = [self searchRequestParametersWithToken:accessToken query:query];
        [self getTracksWithParameters:parameters completion:completion];
    } else {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
    }
    
}

- (void)getTrackWithUPC:(NSString *)upc completion:(void (^)(Track *track, NSError *error))completion {
    
    NSString *accessToken = [self validateMusicCatalog]; // nil if MusicPlayerManager has not authorized correctly
    
    if (!accessToken) {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
        return;
    }
    
    NSDictionary *parameters = [self upcLookupParametersWithToken:accessToken upc:upc];
    [self getTrackWithUPC:upc parameters:parameters completion:completion];
    
}

# pragma mark - Helpers

- (void)postFailedAuthorizationNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicAPIManagerFailedAccessTokenNotification object:self];
}

- (NSDictionary *)upcLookupParametersWithToken:(NSString *)token upc:(NSString *)upc {
    
    NSString *upcQuery = [NSString stringWithFormat:@"upc:%@", upc];
    NSString *tokenParameterName = [_musicCatalog tokenParameterName];
    NSString *typeParameterName = [_musicCatalog typeParameterName];
    NSString *limitParameterName = [_musicCatalog limitParameterName];
    NSString *queryParameterName = [_musicCatalog queryParameterName];
    NSString *trackTypeName = [_musicCatalog trackTypeName];
    
    NSDictionary *parameters = @{tokenParameterName:token,
                                 limitParameterName:@(1),
                                 queryParameterName:upcQuery,
                                 typeParameterName:trackTypeName};
    return parameters;
    
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

- (NSString *)streamingIdForRequest:(Request *)request {
    
    StreamingService streamingService = [[MusicPlayerManager shared] streamingService];
    
    if (streamingService == AppleMusic) {
        return request.appleMusicId;
    }
    
    return request.spotifyId;
    
}

- (NSString *)validateMusicCatalog {
    
    StreamingService streamingService = [[MusicPlayerManager shared] streamingService];
    
    if (!streamingService) {
        return nil;
    }
    
    if (streamingService == AppleMusic) {
        _musicCatalog = AppleMusicCatalog;
    } else {
        _musicCatalog = SpotifyCatalog;
    }
    
    return [[MusicPlayerManager shared] accessToken];
    
}

@end
