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

+ (void)getAllVotesForSongWithId:(NSString *)songId {
    PFQuery *query = [SNDParseManager queryForAllVotesWithSongId:songId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            for (PFObject *object in objects) {
                
            }
        }
    }];
}

+ (NSNumber *)scoreForSongWithId:(NSString *)songId {
    
    NSNumber *finalScore = 0;
    NSString *roomId = [[RoomManager shared] currentRoomId];
    
    if (roomId) {
        __block int score = 0;
        PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
        [query whereKey:@"songId" equalTo:songId];
        [query whereKey:@"roomId" equalTo:roomId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
                for (Vote *vote in objects) {
                    score += [vote.increment intValue];
                }
            }
        }];
    }
    
    return finalScore;
    
}

+ (NSNumber *)scoreForSong:(QueueSong *)song {
    return [self scoreForSongWithId:song.objectId];
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
    
    BOOL __block didUpvote = NO;
    
    PFQuery *query = [self queryWithSongId:songId];
    [query whereKey:@"increment" equalTo:@(1)];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            didUpvote = YES;
        }
    }];
    
    return didUpvote;
}

+ (BOOL)didDownvoteSongWithId:(NSString *)songId {
    
    BOOL __block didDownvote = NO;
    
    PFQuery *query = [self queryWithSongId:songId];
    [query whereKey:@"increment" equalTo:@(-1)];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects) {
            didDownvote = YES;
        }
    }];
    
    return didDownvote;
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
