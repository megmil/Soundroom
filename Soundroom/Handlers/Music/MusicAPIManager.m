//
//  MusicAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/1/22.
//

#import "MusicAPIManager.h"
#import "MusicPlayerManager.h"
#import "DeezerAPIManager.h"
#import "SpotifyAPIManager.h"
#import "AppleMusicAPIManager.h"
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
    
    NSString *searchURLString = [_musicCatalog searchURLString];
    
    [_musicCatalog GET:searchURLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id response) {
        NSArray *tracks = [self->_musicCatalog tracksWithJSONResponse:response];
        completion(tracks, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
    
}

- (void)getTrackWithISRC:(NSString *)isrc parameters:(NSDictionary *)parameters completion:(void(^)(Track *track, NSError *error))completion {
    
    NSString *lookupURLString = [_musicCatalog lookupURLStringWithISRC:isrc];
    
    [_musicCatalog GET:lookupURLString parameters:parameters headers:nil progress:nil success:^(NSURLSessionDataTask *task, id response) {
        Track *track = [self->_musicCatalog trackWithJSONResponse:response];
        completion(track, nil);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        completion(nil, error);
    }];
    
}

# pragma mark - Public

- (void)getTracksWithQuery:(NSString *)query completion:(void(^)(NSArray *tracks, NSError *error))completion {
    NSString *accessToken = [self validateStreamingService];
    NSDictionary *parameters = [_musicCatalog searchParametersWithToken:accessToken query:query];
    [self getTracksWithParameters:parameters completion:completion];
}

- (void)getTrackWithISRC:(NSString *)isrc completion:(void (^)(Track *track, NSError *error))completion {
    NSString *accessToken = [self validateStreamingService];
    NSDictionary *parameters = [_musicCatalog lookupParametersWithToken:accessToken isrc:isrc];
    [self getTrackWithISRC:isrc parameters:parameters completion:completion];
}

# pragma mark - Helpers

- (NSString *)validateStreamingService {
    
    if ([[MusicPlayerManager shared] streamingService] == AppleMusic) {
        _musicCatalog = [AppleMusicAPIManager shared];
    } else if ([[MusicPlayerManager shared] streamingService] == Spotify) {
        _musicCatalog = [SpotifyAPIManager shared];
    } else {
        _musicCatalog = [DeezerAPIManager shared];
    }
    
    return [[MusicPlayerManager shared] accessToken];
    
}

- (void)postFailedAuthorizationNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:MusicAPIManagerFailedAccessTokenNotification object:nil];
}

@end
