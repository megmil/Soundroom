//
//  Track.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Track.h"

@implementation Track

static NSString *const tracksJSONResponsePathName = @"tracks";
static NSString *const itemsJSONResponsePathName = @"items";

static NSString *const spotifyJSONResponseItemNameKey = @"name";
static NSString *const spotifyJSONResponseTrackURIKey = @"uri";
static NSString *const spotifyJSONResponseTrackUPCKey = @"upc";
static NSString *const spotifyJSONResponseTrackArtistKey = @"artists";
static NSString *const spotifyJSONResponseArtistSeparatorString = @", ";
static NSString *const spotifyJSONResponseTrackAlbumKey = @"album";
static NSString *const spotifyJSONResponseAlbumImagesKey = @"images";
static NSString *const spotifyJSONResponseAlbumImageURLKey = @"url";

+ (NSArray *)tracksWithJSONResponse:(NSDictionary *)response {
    NSDictionary *tracksJSONResponses = response[@"tracks"][@"items"];
    NSMutableArray *tracks = [NSMutableArray array];
    for (NSDictionary *trackJSONResponse in tracksJSONResponses) {
        Track *track = [[Track alloc] initWithJSONResponse:trackJSONResponse];
        [tracks addObject:track];
    }
    return tracks;
}

+ (Track *)trackWithJSONResponse:(NSDictionary *)response {
    Track *track = [[Track alloc] initWithJSONResponse:response];
    return track;
}

- (instancetype)initWithJSONResponse:(NSDictionary *)response {
    
    self = [super init];
    
    if (self) {
        
        _upc = response[spotifyJSONResponseTrackUPCKey];
        _streamingId = response[spotifyJSONResponseTrackURIKey];
        _title = response[spotifyJSONResponseItemNameKey];
        
        // format artists into one string
        NSMutableArray <NSString *> *artists = [NSMutableArray array];
        for (NSDictionary *artist in response[spotifyJSONResponseTrackArtistKey]) {
            [artists addObject:artist[spotifyJSONResponseItemNameKey]];
        }
        _artist = [artists componentsJoinedByString:spotifyJSONResponseArtistSeparatorString];
        
        // get album details
        NSDictionary *album = response[spotifyJSONResponseTrackAlbumKey];
        NSString *albumImageURLString = [album[spotifyJSONResponseAlbumImagesKey] firstObject][spotifyJSONResponseAlbumImageURLKey];
        NSURL *albumImageURL = [NSURL URLWithString:albumImageURLString];
        NSData *albumImageData = [NSData dataWithContentsOfURL:albumImageURL];
        _albumImage = [UIImage imageWithData:albumImageData];
        
    }
    
    return self;
    
}

@end
