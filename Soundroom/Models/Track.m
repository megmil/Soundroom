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
static NSString *const spotifyJSONResponseTrackIdKey = @"id";
static NSString *const spotifyJSONResponseTrackURIKey = @"uri";
static NSString *const spotifyJSONResponseTrackArtistKey = @"artists";
static NSString *const spotifyJSONResponseTrackAlbumKey = @"album";
static NSString *const spotifyJSONResponseTrackDurationKey = @"duration_ms";
static NSString *const spotifyJSONResponseArtistSeparatorString = @", ";
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
        
        self.spotifyId = response[spotifyJSONResponseTrackIdKey];
        self.spotifyURI = response[spotifyJSONResponseTrackURIKey];
        self.title = response[spotifyJSONResponseItemNameKey];
        
        // format artists into one string
        NSMutableArray <NSString *> *artists = [NSMutableArray array];
        for (NSDictionary *artist in response[spotifyJSONResponseTrackArtistKey]) {
            [artists addObject:artist[spotifyJSONResponseItemNameKey]];
        }
        self.artist = [artists componentsJoinedByString:spotifyJSONResponseArtistSeparatorString];
        
        // get album details
        NSDictionary *album = response[spotifyJSONResponseTrackAlbumKey];
        self.albumTitle = album[spotifyJSONResponseItemNameKey];
        NSString *albumImageURLString = [album[spotifyJSONResponseAlbumImagesKey] firstObject][spotifyJSONResponseAlbumImageURLKey];
        NSURL *albumImageURL = [NSURL URLWithString:albumImageURLString];
        NSData *albumImageData = [NSData dataWithContentsOfURL:albumImageURL];
        self.albumImage = [UIImage imageWithData:albumImageData];
        
        // format duration (ms) for display (mm:ss)
        NSNumber *millisecondsNumber = [response valueForKey:spotifyJSONResponseTrackDurationKey];
        int milliseconds = [millisecondsNumber intValue];
        int minutes = milliseconds / 60000;
        int seconds = (milliseconds % 60000) / 1000;
        self.durationString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
        
    }
    
    return self;
    
}

@end
