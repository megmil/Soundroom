//
//  DeezerAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/2/22.
//

#import "DeezerAPIManager.h"
#import "Track.h"

static NSString *const baseURLString = @"https://api.deezer.com";
static NSString *const searchURLString = @"search/track?";
static NSString *const lookupURLString = @"2.0/track/isrc:%@";
static NSString *const getTrackURLString = @"track/%@";

static NSString *const queryParameterName = @"q";
static NSString *const limitParameterName = @"limit";
static NSNumber *const searchLimit = @(10);

static NSString *const deezerJSONResponseTracksPathName = @"data";
static NSString *const deezerJSONResponseIdKey = @"id";
static NSString *const deezerJSONResponseTitleKey = @"title";
static NSString *const deezerJSONResponseArtistKey = @"artist";
static NSString *const deezerJSONResponseArtistNameKey = @"name";
static NSString *const deezerJSONResponseAlbumKey = @"album";
static NSString *const deezerJSONResponseAlbumImageKey = @"cover";
static NSString *const deezerJSOnResponseISRCKey = @"isrc";

@implementation DeezerAPIManager

+ (instancetype)shared {
    static DeezerAPIManager *sharedManager;
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

# pragma mark - Search

- (NSString *)searchURLString {
    return searchURLString;
}

- (NSDictionary *)searchParametersWithToken:(NSString *)token query:(NSString *)query {
    NSDictionary *parameters = @{queryParameterName:query,
                                 limitParameterName:searchLimit};
    return parameters;
}

# pragma mark - Lookup

- (NSString *)lookupURLStringWithISRC:(NSString *)isrc {
    return [NSString stringWithFormat:lookupURLString, isrc];
}

- (NSDictionary *)lookupParametersWithToken:(NSString *)token isrc:(NSString *)isrc {
    return nil;
}

# pragma mark - ISRC

- (void)getISRCWithDeezerId:(NSString *)deezerId completion:(void (^)(NSString *))completion {
    
    NSString *urlString = [NSString stringWithFormat:getTrackURLString, deezerId];
    
    [self GET:urlString parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask *task, id response) {
        NSString *isrc = response[deezerJSOnResponseISRCKey];
        completion(isrc);
    } failure:nil];
    
}

# pragma mark - Decoding

- (NSArray<Track *> *)tracksWithJSONResponse:(NSDictionary *)response {
    
    NSArray *tracksJSONResponses = response[deezerJSONResponseTracksPathName];
    NSMutableArray *tracks = [NSMutableArray array];
    
    for (NSDictionary *trackJSONResponse in tracksJSONResponses) {
        Track *track = [self trackWithJSONResponse:trackJSONResponse];
        [tracks addObject:track];
    }
    
    return tracks;
    
}

- (Track *)trackWithJSONResponse:(NSDictionary *)response {
    
    NSString *deezerId = response[deezerJSONResponseIdKey];
    NSString *title = response[deezerJSONResponseTitleKey];
    NSString *artist = response[deezerJSONResponseArtistKey][deezerJSONResponseArtistNameKey];
    NSString *albumImageURLString = response[deezerJSONResponseAlbumKey][deezerJSONResponseAlbumImageKey];
    NSURL *albumImageURL = [NSURL URLWithString:albumImageURLString];
    
    Track *track = [[Track alloc] initWithDeezerId:deezerId title:title artist:artist albumImageURL:albumImageURL];
    return track;
    
}

@end
