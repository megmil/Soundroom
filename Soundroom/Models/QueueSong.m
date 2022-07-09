//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"
#import "Realm/Realm.h"

@implementation QueueSong

- (instancetype)initWithSong:(Song *)song {
    
    self = [super init];
    
    if (self) {
        self.idString = song.idString;
        self.score = 0;
    }
    
    return self;
}

- (void)addToQueue {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [realm addObject:self];
    [realm commitAsyncWriteTransaction]; // TODO: completion
}

@end
