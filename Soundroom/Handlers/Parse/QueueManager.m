//
//  ParseQueueManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "QueueManager.h"
#import "RoomManager.h"
#import "VoteManager.h"
#import "Vote.h"
#import "SNDParseManager.h"

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

+ (void)getSpotifyIdForSongWithId:(NSString *)songId completion:(PFStringResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query getObjectInBackgroundWithId:songId block:^(PFObject *object, NSError *error) {
        if (object) {
            QueueSong *song = (QueueSong *)object;
            completion(song.spotifyId, error);
        } else {
            completion(nil, error);
        }
    }];
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
    [VoteManager loadScoresForQueue:_queue completion:^(NSMutableArray<NSNumber *> *scores) {
        
        if (!scores) {
            return;
        }
        
        // create permutation array to log order change
        NSMutableArray <NSNumber *> *permutationArray = [NSMutableArray arrayWithCapacity:scores.count];
        for (NSUInteger i = 0; i != scores.count; i++) {
            [permutationArray addObject:[NSNumber numberWithInteger:i]];
        }
        
        // sort permutation array according to scores
        [permutationArray sortWithOptions:0 usingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSNumber *lhs = [scores objectAtIndex:[obj1 intValue]];
            NSNumber *rhs = [scores objectAtIndex:[obj2 intValue]];
            return [lhs compare:rhs];
        }];
        
        // use the permutation to re-order the queue and scores
        NSMutableArray <QueueSong *> *sortedQueue = [NSMutableArray arrayWithCapacity:scores.count];
        NSMutableArray <NSNumber *> *sortedScores = [NSMutableArray arrayWithCapacity:scores.count];
        [permutationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSUInteger pos = [obj intValue];
            [sortedQueue addObject:[self->_queue objectAtIndex:pos]];
            [sortedScores addObject:[scores objectAtIndex:pos]];
        }];
        
        self->_queue = sortedQueue;
        self->_scores = sortedScores;
        
    }];
}

# pragma mark - Update Queue: Private

- (void)_updateQueueSong:(QueueSong *)song completion:(void (^)(BOOL succeeded))completion {
    [self _removeQueueSong:song];
    [self _insertQueueSong:song completion:completion];
}

- (void)_removeQueueSong:(QueueSong *)song {
    NSUInteger index = [_queue indexOfObject:song];
    if (index != NSNotFound) {
        [_queue removeObjectAtIndex:index];
        [_scores removeObjectAtIndex:index];
    }
}

- (void)_insertQueueSong:(QueueSong *)song completion:(void (^)(BOOL succeeded))completion {
    
    [VoteManager scoreForSongWithId:song.objectId completion:^(NSNumber *result) {
        
        NSUInteger score = [result unsignedIntegerValue];
        
        // empty queue
        if (!self->_queue || !self->_queue.count) {
            self->_queue = [NSMutableArray arrayWithObject:song];
            self->_scores = [NSMutableArray arrayWithObject:@(score)];
            completion(YES);
            return;
        }
            
        // insert queue song at lowest position
        for (NSUInteger i = self->_scores.count - 1; i >= 0; i--) {
            NSUInteger current = [[self->_scores objectAtIndex:i] unsignedIntegerValue];
            if (score <= current || i == 0) {
                [self->_queue insertObject:song atIndex:i]; // TODO: i + 1
                [self->_scores insertObject:@(score) atIndex:i];
                completion(YES);
                return;
            }
        }
        
    }];
    
}

# pragma mark - Update Queue: Public

- (void)updateQueueSongWithId:(NSString * _Nonnull )songId {
    QueueSong *song = [PFQuery getObjectOfClass:@"QueueSong" objectId:songId];
    if (song && [_queue containsObject:song]) {
        [self _updateQueueSong:song completion:^(BOOL succeeded) {
            if (succeeded) {
                [self postUpdatedQueueNotification];
            }
        }];
    }
}

- (void)removeQueueSong:(QueueSong *)song {
    if ([_queue containsObject:song]) {
        [self _removeQueueSong:song];
        [self postUpdatedQueueNotification];
    }
}

- (void)insertQueueSong:(QueueSong *)song {
    [self _insertQueueSong:song completion:^(BOOL succeeded) {
        if (succeeded) {
            [self postUpdatedQueueNotification];
        }
    }];
}

- (NSMutableArray <QueueSong *> *)queue {
    return _queue;
}

- (NSMutableArray<NSNumber *> *)scores {
    return _scores;
}


# pragma mark - Helpers

- (void)postUpdatedQueueNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:QueueManagerUpdatedQueueNotification object:self];
}

@end
