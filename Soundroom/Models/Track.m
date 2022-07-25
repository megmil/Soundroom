//
//  Track.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Track.h"

@implementation Track

+ (NSMutableArray *)tracksWithJSONResponse:(NSDictionary *)response {
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
        self.spotifyId = response[@"id"];
        self.spotifyURI = response[@"uri"];
        self.title = response[@"name"];
        
        // format artists into one string
        NSMutableArray <NSString *> *artists = [NSMutableArray array];
        for (NSDictionary *artist in response[@"artists"]) {
            [artists addObject:artist[@"name"]];
        }
        self.artist = [artists componentsJoinedByString:@", "];
        
        // get album details
        NSDictionary *album = response[@"album"];
        self.albumTitle = album[@"name"];
        NSString *albumImageURLString = [album[@"images"] firstObject][@"url"];
        NSURL *albumImageURL = [NSURL URLWithString:albumImageURLString];
        NSData *albumImageData = [NSData dataWithContentsOfURL:albumImageURL];
        self.albumImage = [UIImage imageWithData:albumImageData];
        
        // format duration (ms) for display (mm:ss)
        NSNumber *millisecondsNumber = [response valueForKey:@"duration_ms"];
        int milliseconds = [millisecondsNumber intValue];
        int minutes = milliseconds / 60000;
        int seconds = (milliseconds % 60000) / 1000;
        self.durationString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
    
    return self;
    
}

@end
