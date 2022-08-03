//
//  Track.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "Track.h"

@implementation Track

- (instancetype)initWithISRC:(NSString *)isrc streamingId:(NSString *)streamingId title:(NSString *)title artist:(NSString *)artist albumImageURL:(NSURL *)albumImageURL {
    
    self = [super init];
    
    if (self) {
        
        _isrc = isrc;
        _streamingId = streamingId;
        _title = title;
        _artist = artist;
        _albumImageURL = albumImageURL;
        
    }
    
    return self;
    
}

- (instancetype)initWithDeezerId:(NSString *)deezerId title:(NSString *)title artist:(NSString *)artist albumImageURL:(NSURL *)albumImageURL {
    
    self = [super init];
    
    if (self) {
        
        _deezerId = deezerId;
        _title = title;
        _artist = artist;
        _albumImageURL = albumImageURL;
        
    }
    
    return self;
    
}

@end
