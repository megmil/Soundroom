//
//  Song.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Song.h"

@implementation Song

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

+ (NSMutableArray *)songsWithArray:(NSArray *)dictionaries {
    NSMutableArray *songs = [NSMutableArray array];
    for (NSDictionary *dictionary in dictionaries) {
        Song *song = [[Song alloc] initWithDictionary:dictionary];
        [songs addObject:song];
    }
    return songs;
}

@end
