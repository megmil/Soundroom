//
//  SpotifyAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/2/22.
//

#import "SpotifyAPIManager.h"
#import "Track.h"

static NSString *const baseURLString = @"https://api.spotify.com";
static NSString *const searchURLString = @"v1/search?";

static NSString *const tokenParameterName = @"access_token";
static NSString *const limitParameterName = @"limit";
static NSString *const typeParameterName = @"type";
static NSString *const queryParameterName = @"q";
static NSString *const trackTypeName = @"track";
static NSString *const isrcParameterFormat = @"isrc:%@";

static NSString *const spotifyJSONResponseTracksPathName = @"tracks";
static NSString *const spotifyJSONResponseItemsPathName = @"items";
static NSString *const spotifyJSONResponseIdKey = @"uri";
static NSString *const spotifyJSONResponseNameKey = @"name";
static NSString *const spotifyJSONResponseArtistKey = @"artists";
static NSString *const spotifyJSONResponseAlbumKey = @"album";
static NSString *const spotifyJSONResponseImagesKey = @"images";
static NSString *const spotifyJSONResponseURLKey = @"url";
static NSString *const spotifyJSONResponseExternalIdsKey = @"external_ids";
static NSString *const spotifyJSONResponseISRCKey = @"isrc";
static NSString *const spotifyJSONResponseSeparator = @", ";

static const NSNumber *lookupLimit = @(1);

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

# pragma mark - Search

- (NSString *)searchURLString {
    return searchURLString;
}

- (NSDictionary *)searchParametersWithToken:(NSString *)token query:(NSString *)query  {
    NSDictionary *parameters = @{tokenParameterName:token,
                                 typeParameterName:trackTypeName,
                                 queryParameterName:query};
    return parameters;
}

# pragma mark - Lookup

- (NSString *)lookupURLStringWithISRC:(NSString *)isrc {
    return searchURLString;
}

- (NSDictionary *)lookupParametersWithToken:(NSString *)token isrc:(NSString *)isrc {
    
    NSString *query = [NSString stringWithFormat:isrcParameterFormat, isrc];
    
    if (token == nil) {
        token = @"";
    }
    
    NSDictionary *parameters = @{tokenParameterName:token,
                                 limitParameterName:lookupLimit,
                                 queryParameterName:query,
                                 typeParameterName:trackTypeName};
    return parameters;
    
}

# pragma mark - Decoding

- (NSArray<Track *> *)tracksWithJSONResponse:(NSDictionary *)response {
    NSArray *tracksJSONResponses = response[spotifyJSONResponseTracksPathName][spotifyJSONResponseItemsPathName];
    NSMutableArray *tracks = [NSMutableArray array];
    for (NSDictionary *trackJSONResponse in tracksJSONResponses) {
        Track *track = [self trackWithJSONResponse:trackJSONResponse];
        [tracks addObject:track];
    }
    return tracks;
}

- (Track *)trackWithJSONResponse:(NSDictionary *)response isrc:(NSString *)isrc {
    return [self tracksWithJSONResponse:response].firstObject;
}

- (Track *)trackWithJSONResponse:(NSDictionary *)response {
    
    NSString *isrc = response[spotifyJSONResponseExternalIdsKey][spotifyJSONResponseISRCKey];
    NSString *streamingId = response[spotifyJSONResponseIdKey];
    NSString *title = response[spotifyJSONResponseNameKey];
    NSString *artist = [self artistNamesWithJSONResponse:response];
    NSURL *albumImageURL = [self albumImageURLWithJSONResponse:response];
    
    Track *track = [[Track alloc] initWithISRC:isrc streamingId:streamingId title:title artist:artist albumImageURL:albumImageURL];
    
    return track;
    
}

- (NSURL *)albumImageURLWithJSONResponse:(NSDictionary *)response {
    NSString *albumImageURLString = [response[spotifyJSONResponseAlbumKey][spotifyJSONResponseImagesKey] firstObject][spotifyJSONResponseURLKey];
    NSURL *albumImageURL = [NSURL URLWithString:albumImageURLString];
    return albumImageURL;
}

- (NSString *)artistNamesWithJSONResponse:(NSDictionary *)response {
    NSMutableArray <NSString *> *artists = [NSMutableArray <NSString *> new];
    for (NSDictionary *artist in response[spotifyJSONResponseArtistKey]) {
        [artists addObject:artist[spotifyJSONResponseNameKey]];
    }
    return [artists componentsJoinedByString:spotifyJSONResponseSeparator];
}

@end
