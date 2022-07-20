//
//  ParseQueueManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "QueueManager.h"
#import "RoomManager.h"
#import "VoteManager.h"

@implementation QueueManager {
    NSMutableArray <QueueSong *> *_queue;
    NSMutableArray <NSNumber *> *_scores;
}

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (void)playTopSong {
    if (_queue.count) {
        // get and remove first song from queue
        QueueSong *topSong = _queue.firstObject;
        [self _removeQueueSong:topSong];
        
        // save current song to room
        [[RoomManager shared] updateRoomWithCurrentSongId:topSong.objectId];
    }
}

# pragma mark - QueueSongs

+ (void)requestSongWithSpotifyId:(NSString *)spotifyId {
    
    NSString *currentRoomId = [[RoomManager shared] currentRoomId];
    if (currentRoomId) {
        QueueSong *newSong = [QueueSong new];
        newSong.spotifyId = spotifyId;
        newSong.roomId = currentRoomId;
        [newSong saveInBackground];
    }
    
}

+ (NSString *)getSpotifyIdForSongWithId:(NSString *)songId {
    QueueSong *song = [PFQuery getObjectOfClass:@"QueueSong" objectId:songId];
    if (song) {
        return song.spotifyId;
    }
    return nil;
}

# pragma mark - Fetch Queue

- (void)resetQueue {
    _queue = [NSMutableArray <QueueSong *> array];
    _scores = [NSMutableArray <NSNumber *> array];
}

- (void)fetchQueue {
    
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (roomId) {
        PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
        [query whereKey:@"roomId" equalTo:roomId];
        [query orderByAscending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
                self->_queue = (NSMutableArray <QueueSong *> *)objects;
                [self sortQueue];
                [self postUpdatedQueueNotification];
            }
        }];
    }
    
}

- (void)sortQueue {
    
    // calculate score for each queue song
    _scores = [NSMutableArray arrayWithCapacity:_queue.count];
    for (QueueSong *song in _queue) {
        NSNumber *score = [VoteManager scoreForSongWithId:song.objectId];
        [_scores addObject:score];
    }
    
    // create permutation array to log order change
    NSMutableArray <NSNumber *> *permutationArray = [NSMutableArray arrayWithCapacity:_queue.count];
    for (NSUInteger i = 0; i != _queue.count; i++) {
        [permutationArray addObject:[NSNumber numberWithInteger:i]];
    }
    
    // sort permutation array according to scores
    [permutationArray sortWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *lhs = [_scores objectAtIndex:[obj1 intValue]];
        NSNumber *rhs = [_scores objectAtIndex:[obj2 intValue]];
        return [lhs compare:rhs];
    }];
    
    // use the permutation to re-order the queue and scores
    NSMutableArray <QueueSong *> *sortedQueue = [NSMutableArray arrayWithCapacity:_queue.count];
    NSMutableArray <NSNumber *> *sortedScores = [NSMutableArray arrayWithCapacity:_queue.count];
    [permutationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSUInteger pos = [obj intValue];
        [sortedQueue addObject:[_queue objectAtIndex:pos]];
        [sortedScores addObject:[_scores objectAtIndex:pos]];
    }];
    
    _queue = sortedQueue;
    _scores = sortedScores;
    
}

# pragma mark - Update Queue: Private

- (void)_updateQueueSong:(QueueSong *)song {
    [self removeQueueSong:song];
    [self insertQueueSong:song];
}

- (void)_removeQueueSong:(QueueSong *)song {
    NSUInteger index = [_queue indexOfObject:song];
    if (index) {
        [_queue removeObjectAtIndex:index];
        [_scores removeObjectAtIndex:index];
    }
}

- (void)_insertQueueSong:(QueueSong *)song {
    
    NSUInteger score = [[VoteManager scoreForSongWithId:song.objectId] intValue];
    
    // empty queue
    if (!_queue || !_queue.count) {
        _queue = [NSMutableArray arrayWithObject:song];
        _scores = [NSMutableArray arrayWithObject:@(score)];
        return;
    }
    
    // insert queue song at lowest position
    for (NSUInteger i = _scores.count - 1; i >= 0; i--) {
        NSUInteger current = [[_scores objectAtIndex:i] intValue];
        if (score <= current || i == 0) {
            [_queue insertObject:song atIndex:i];
            [_scores insertObject:@(score) atIndex:i];
            return;
        }
    }
}

# pragma mark - Update Queue: Public

- (void)updateQueueSong:(QueueSong *)song {
    if ([_queue containsObject:song]) {
        [self _updateQueueSong:song];
        [self postUpdatedQueueNotification];
    }
}

- (void)removeQueueSong:(QueueSong *)song {
    if ([_queue containsObject:song]) {
        [self _removeQueueSong:song];
        [self postUpdatedQueueNotification];
    }
}

- (void)insertQueueSong:(QueueSong *)song {
    [self _insertQueueSong:song];
    [self postUpdatedQueueNotification];
}

- (NSMutableArray <QueueSong *> *)queue {
    return _queue;
}


# pragma mark - Helpers

- (void)postUpdatedQueueNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:QueueManagerUpdatedQueueNotification object:self];
}

@end
