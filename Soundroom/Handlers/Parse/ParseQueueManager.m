//
//  ParseQueueManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "ParseQueueManager.h"
#import "ParseRoomManager.h"
#import "Vote.h"

@implementation ParseQueueManager {
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

// TODO: delete queue songs when room is deleted

# pragma mark - Update Queue

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
    
    NSUInteger score = [[Vote scoreForSongWithId:song.objectId] intValue];
    
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

# pragma mark - Fetch Queue

- (void)fetchQueue {
    
    NSString *roomId = [[ParseRoomManager shared] currentRoomId];
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
        NSNumber *score = [Vote scoreForSongWithId:song.objectId];
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

# pragma mark - Public

- (void)updateQueueSong:(QueueSong *)song {
    [self _updateQueueSong:song];
    [self postUpdatedQueueNotification];
}

- (void)removeQueueSong:(QueueSong *)song {
    [self _removeQueueSong:song];
    [self postUpdatedQueueNotification];
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
