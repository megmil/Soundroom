//
//  Song.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Song.h"
#import "QueueSong.h"

@implementation Song

+ (NSMutableArray *)songsWithDictionary:(NSDictionary *)dictionary {
    NSDictionary *dictionaries = dictionary[@"tracks"][@"items"];
    NSMutableArray *songs = [NSMutableArray array];
    for (NSDictionary *songDictionary in dictionaries) {
        Song *song = [[Song alloc] initWithDictionary:songDictionary];
        [songs addObject:song];
    }
    return songs;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        self.idString = dictionary[@"id"];
        self.title = dictionary[@"name"];
        
        // format artists into one string
        NSMutableArray <NSString *> *artists = [NSMutableArray array];
        for (NSDictionary *artist in dictionary[@"artists"]) {
            [artists addObject:artist[@"name"]];
        }
        self.artist = [artists componentsJoinedByString:@", "];
        
        // get album details
        NSDictionary *album = dictionary[@"album"];
        self.albumTitle = album[@"name"];
        NSString *albumImageURLString = [album[@"images"] firstObject][@"url"];
        NSURL *albumImageURL = [NSURL URLWithString:albumImageURLString];
        self.albumImageData = [NSData dataWithContentsOfURL:albumImageURL];
        
        // format duration (ms) for display (mm:ss)
        NSNumber *millisecondsNumber = [dictionary valueForKey:@"duration_ms"];
        int milliseconds = [millisecondsNumber intValue];
        int minutes = milliseconds / 60000;
        int seconds = (milliseconds % 60000) / 1000;
        self.durationString = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    }
    
    return self;
}

- (void)addToQueue {
    QueueSong *queueSong = [[QueueSong alloc] initWithSong:self];
    [queueSong addToQueue];
}

@end
