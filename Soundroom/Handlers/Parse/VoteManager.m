//
//  VoteManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/20/22.
//

#import "VoteManager.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "SNDParseManager.h"
#import "Vote.h"

@implementation VoteManager

+ (void)incrementSong:(QueueSong *)song byAmount:(NSNumber *)amount {
    [self incrementSongWithId:song.objectId byAmount:amount];
}

+ (void)incrementSongWithId:(NSString *)songId byAmount:(NSNumber *)amount {
    
    // check for duplicate
    [self getVotesForSongWithId:songId completion:^(PFObject *object, NSError *error) {
        if (object) {
            // update duplicate vote
            Vote *vote = (Vote *)object;
            vote.increment = amount;
            [vote saveInBackground];
        } else {
            // create new vote
            Vote *newVote = [Vote new];
            newVote.songId = songId;
            newVote.userId = [ParseUserManager currentUserId];
            newVote.roomId = [[RoomManager shared] currentRoomId];
            newVote.increment = amount;
            [newVote saveInBackground];
        }
    }];
    
}

+ (void)getVotesForSongWithId:(NSString *)songId completion:(PFObjectResultBlock)completion {
    
    PFQuery *query = [SNDParseManager queryForUserVotesWithSongId:songId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            // this song has already been voted on (should only be one object)
            completion(objects.firstObject, nil);
        } else {
            // this song has not been voted on
            completion(nil, error);
        }
    }];
    
}

+ (void)loadScoresForQueue:(NSMutableArray <QueueSong *> *)queue completion:(void (^)(NSMutableArray <NSNumber *> *scores))completion {
    
    NSMutableArray <NSNumber *> *scores = [NSMutableArray arrayWithCapacity:queue.count];
    for (NSUInteger i = 0; i != queue.count; i++) {
        [scores addObject:@(0)];
    }
    
    PFQuery *query = [[SNDParseManager shared] queryForAllVotesInRoom];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        for (Vote *vote in objects) {
            
            QueueSong *song = [PFQuery getObjectOfClass:@"QueueSong" objectId:vote.songId];
            NSUInteger index = [queue indexOfObject:song];
            
            if (index != NSNotFound) {
                NSNumber *currentScore = [scores objectAtIndex:index];
                NSNumber *newScore = @(currentScore.integerValue + vote.increment.integerValue);
                [scores replaceObjectAtIndex:index withObject:newScore];
            }
            
        }
        
        completion(scores);
        
    }];
}

+ (void)scoreForSongWithId:(NSString *)songId completion:(void (^)(NSNumber *result))completion {
    PFQuery *query = [SNDParseManager queryForAllVotesWithSongId:songId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        __block NSInteger score = 0;
        for (Vote *vote in objects) {
            score += vote.increment.integerValue;
        }
        completion(@(score));
    }];
}

+ (void)scoreForSongWithId:(NSString *)songId initialScore:(NSNumber *)initialScore completion:(void (^)(NSNumber *result))completion {
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
    PFQuery *query = [SNDParseManager queryForAllVotesWithSongId:songId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        __block NSInteger score = initialScore.integerValue;
        dispatch_async(queue, ^{
            if (completion) {
                for (Vote *vote in objects) {
                    score += vote.increment.integerValue;
                }
                completion(@(score));
            }
        });
    }];
}

+ (VoteState)voteStateForSong:(QueueSong *)song {
    return [self voteStateForSongWithId:song.objectId];
}

+ (VoteState)voteStateForSongWithId:(NSString *)songId {
    
    if ([self didUpvoteSongWithId:songId]) {
        return Upvoted;
    }
    
    if ([self didDownvoteSongWithId:songId]) {
        return Downvoted;
    }
    
    return NotVoted;
    
}

+ (BOOL)didUpvoteSongWithId:(NSString *)songId {
    
    PFQuery *query = [self queryWithSongId:songId];
    [query whereKey:@"increment" equalTo:@(1)];
    NSArray *objects = [query findObjects];
    if (objects) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)didDownvoteSongWithId:(NSString *)songId {
    
    PFQuery *query = [self queryWithSongId:songId];
    [query whereKey:@"increment" equalTo:@(-1)];
    NSArray *objects = [query findObjects];
    if (objects) {
        return YES;
    }
    
    return NO;
    
}

+ (BOOL)didNotVoteSongWithId:(NSString *)songId {
    return ![self didUpvoteSongWithId:songId] && ![self didDownvoteSongWithId:songId];
}

+ (PFQuery *)queryWithSongId:(NSString *)songId {
    
    NSString *userId = [ParseUserManager currentUserId];
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"songId" equalTo:songId];
    [query whereKey:@"userId" equalTo:userId];
    [query whereKey:@"roomId" equalTo:roomId];
    
    return query;
}

@end
