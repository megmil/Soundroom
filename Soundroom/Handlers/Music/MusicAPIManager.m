//
//  MusicAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "MusicAPIManager.h"
#import "MusicPlayerManager.h"
#import "SpotifyAPIManager.h"
#import "iTunesAPIManager.h"
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

# pragma mark - Server

- (void)getTracksWithParameters:(NSDictionary *)parameters completion:(void(^)(NSArray *tracks, NSError *error))completion {
    
    NSString *searchURLString = [_streamingServiceAPIManager searchURLString];
    
    [_streamingServiceAPIManager GET:searchURLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *tracks = [Track tracksWithJSONResponse:responseObject];
        completion(tracks, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
    
}

- (void)getTrackWithParameters:(NSDictionary *)parameters completion:(void(^)(Track *track, NSError *error))completion {
    
    NSString *lookupURLString = [_streamingServiceAPIManager lookupURLString];
    
    [_streamingServiceAPIManager GET:lookupURLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        Track *track = [Track trackWithJSONResponse:responseObject];
        completion(track, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
    
}

# pragma mark - Public

- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion {
    
    NSString *accessToken = [self validateStreamingService]; // nil if MusicPlayerManager has not authorized correctly
    
    if (!accessToken) {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
        return;
    }
    
    NSDictionary *parameters = [_streamingServiceAPIManager searchParametersWithToken:accessToken query:query];
    [self getTracksWithParameters:parameters completion:completion];
    
}

- (void)getTrackWithUPC:(NSString *)upc completion:(void (^)(Track *track, NSError *error))completion {
    
    NSString *accessToken = [self validateStreamingService]; // nil if MusicPlayerManager has not authorized correctly
    
    if (!accessToken) {
        [self postFailedAuthorizationNotification];
        completion(nil, nil);
        return;
    }
    
    NSDictionary *parameters = [_streamingServiceAPIManager lookupParametersWithToken:accessToken upc:upc];
    [self getTrackWithParameters:parameters completion:completion];
    
}

# pragma mark - Helpers

- (NSString *)validateStreamingService {
    
    if ([[MusicPlayerManager shared] streamingService] == AppleMusic) {
        _streamingServiceAPIManager = [iTunesAPIManager shared];
    } else if ([[MusicPlayerManager shared] streamingService] == Spotify) {
        _streamingServiceAPIManager = [SpotifyAPIManager shared];
    } else {
        return nil;
    }
    
    return [[MusicPlayerManager shared] accessToken];
    
}

- (void)postFailedAuthorizationNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicAPIManagerFailedAccessTokenNotification object:nil];
}

@end
