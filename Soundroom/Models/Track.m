//
//  Track.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Track.h"

@implementation Track

- (instancetype)initWithISRC:(NSString *)isrc streamingId:(NSString *)streamingId title:(NSString *)title artist:(NSString *)artist albumImage:(UIImage *)albumImage {
    
    self = [super init];
    
    if (self) {
        _isrc = isrc;
        _streamingId = streamingId;
        _title = title;
        _artist = artist;
        _albumImage = albumImage;
    }
    
    return self;
    
}

- (instancetype)initWithTitle:(NSString *)title artist:(NSString *)artist albumImage:(UIImage *)albumImage {
    
    self = [super init];
    
    if (self) {
        _title = title;
        _artist = artist;
        _albumImage = albumImage;
    }
    
    return self;
    
}

@end
