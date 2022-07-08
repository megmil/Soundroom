//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"

@implementation QueueSong

- (instancetype)initWithSong:(Song *)song {
    
    self = [super init];
    
    if (self) {
        self.song = song;
        self.score = 0;
    }
    
    return self;
}

- (void)addToQueue {
    
}

@end
