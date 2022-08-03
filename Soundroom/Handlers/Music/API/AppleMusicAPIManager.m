//
//  AppleMusicAPIManager.m
//  Soundroom
//
//  Created by Megan Miller on 8/2/22.
//

#import "AppleMusicAPIManager.h"
#import "Track.h"

static NSString *const baseURLString = @"https://api.music.apple.com";
static NSString *const searchURLString = @"v1/catalog/us/songs?";

static NSString *const tokenParameterName = @"access_token";
static NSString *const limitParameterName = @"limit";
static NSString *const isrcParameterName = @"filter[isrc]";
static NSString *const queryParameterName = @"q";
static NSString *const typeParameterName = @"types";
static NSString *const trackTypeName = @"songs";

static NSNumber *const searchLimit = @(20);
static NSNumber *const lookupLimit = @(1);

static NSString *const appleMusicJSONResponseResultsKey = @"results";
static NSString *const appleMusicJSONResponseSongsKey = @"songs";
static NSString *const appleMusicJSONResponseDataKey = @"data";
static NSString *const appleMusicJSONResponseIdKey = @"id";
static NSString *const appleMusicJSONResponseTitleKey = @"name";
static NSString *const appleMusicJSONResponseArtistKey = @"artistName";
static NSString *const appleMusicJSONResponseISRCKey = @"isrc";
static NSString *const appleMusicJSONResponseAttributesKey = @"attributes";
static NSString *const appleMusicJSONResponseArtworkKey = @"artwork";
static NSString *const appleMusicJSONResponseURLKey = @"url";

@implementation AppleMusicAPIManager

+ (instancetype)shared {
    static AppleMusicAPIManager *sharedManager;
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
    NSDictionary *parameters = @{tokenParameterName:token,
                                 queryParameterName:query,
                                 typeParameterName:trackTypeName,
                                 limitParameterName:searchLimit};
    return parameters;
}

# pragma mark - Lookup

- (NSString *)lookupURLStringWithISRC:(NSString *)isrc {
    return searchURLString;
}

- (NSDictionary *)lookupParametersWithToken:(NSString *)token isrc:(NSString *)isrc {
    NSDictionary *parameters = @{tokenParameterName:token,
                                 isrcParameterName:isrc,
                                 limitParameterName:lookupLimit};
    return parameters;
}

# pragma mark - Decoding

- (NSArray<Track *> *)tracksWithJSONResponse:(NSDictionary *)response {
    NSArray *tracksJSONResponses = response[appleMusicJSONResponseResultsKey][appleMusicJSONResponseSongsKey];
    NSMutableArray *tracks = [NSMutableArray array];
    for (NSDictionary *trackJSONResponse in tracksJSONResponses) {
        Track *track = [self trackWithJSONResponse:trackJSONResponse];
        [tracks addObject:track];
    }
    return tracks;
}

- (Track *)trackWithJSONResponse:(NSDictionary *)response {
    
    NSDictionary *trackData = response[appleMusicJSONResponseDataKey];
    NSString *isrc = trackData[appleMusicJSONResponseISRCKey];
    NSString *streamingId = trackData[appleMusicJSONResponseIdKey];
    NSString *title = trackData[appleMusicJSONResponseTitleKey];
    NSString *artist = trackData[appleMusicJSONResponseArtistKey];
    UIImage *albumImage = [self albumImageWithTrackData:trackData];
    
    Track *track = [[Track alloc] initWithISRC:isrc streamingId:streamingId title:title artist:artist albumImage:albumImage];
    return track;
    
}

- (UIImage *)albumImageWithTrackData:(NSDictionary *)trackData {
    NSString *albumImageURLString = trackData[appleMusicJSONResponseAttributesKey][appleMusicJSONResponseArtworkKey][appleMusicJSONResponseURLKey];
    NSURL *albumImageURL = [NSURL URLWithString:albumImageURLString];
    NSData *albumImageData = [NSData dataWithContentsOfURL:albumImageURL];
    UIImage *albumImage = [UIImage imageWithData:albumImageData];
    return albumImage;
}

@end
