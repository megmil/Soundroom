//
//  Song.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Song.h"
#import "QueueSong.h"

@implementation Song

+ (NSMutableArray *)songsWithJSONResponse:(NSDictionary *)response {
    NSDictionary *songsDictionary = response[@"tracks"][@"items"];
    NSMutableArray *songsArray = [NSMutableArray array];
    for (NSDictionary *songDictionary in songsDictionary) {
        Song *song = [[Song alloc] initWithJSONResponse:songDictionary];
        [songsArray addObject:song];
    }
    return songsArray;
}

- (instancetype)initWithJSONResponse:(NSDictionary *)response {
    self = [super init];
    
    if (self) {
        self.spotifyId = response[@"id"];
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

+ (void)queueSongWithSpotifyId:(NSString *)spotifyId completion:(void(^)(NSError *error))completion {
    
}

@end
