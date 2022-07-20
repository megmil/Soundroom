//
//  Upvotes.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "Vote.h"
#import "ParseUserManager.h"
#import "ParseRoomManager.h"

@implementation Vote

@dynamic objectId;
@dynamic songId;
@dynamic userId;
@dynamic roomId;
@dynamic increment;

+ (nonnull NSString *)parseClassName {
    return @"Vote";
}

+ (void)incrementSongWithId:(NSString *)songId byAmount:(NSNumber *)amount {
    
    NSString *userId = [ParseUserManager currentUserId];
    NSString *roomId = [[ParseRoomManager shared] currentRoomId];
    
    // check for duplicate
    [self getVotesForSongWithId:songId userId:userId roomId:roomId completion:^(PFObject *object, NSError *error) {
        if (object) {
            // update duplicate vote
            Vote *vote = (Vote *)object;
            vote.increment = amount;
            [vote saveInBackground];
        } else {
            // create new vote
            Vote *newVote = [Vote new];
            newVote.songId = songId;
            newVote.userId = userId;
            newVote.roomId = roomId;
            newVote.increment = amount;
            [newVote saveInBackground];
        }
    }];
    
}

+ (void)getVotesForSongWithId:(NSString *)songId userId:(NSString *)userId roomId:(NSString *)roomId completion:(PFObjectResultBlock)completion {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"songId" equalTo:songId];
    [query whereKey:@"userId" equalTo:userId];
    [query whereKey:@"roomId" equalTo:roomId];
    
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
    NSString *roomId = [[ParseRoomManager shared] currentRoomId];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
    [query whereKey:@"songId" equalTo:songId];
    [query whereKey:@"userId" equalTo:userId];
    [query whereKey:@"roomId" equalTo:roomId];
    
    return query;
}

@end
