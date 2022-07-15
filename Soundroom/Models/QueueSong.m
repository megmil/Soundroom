//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"
#import "ParseRoomManager.h"

@implementation QueueSong

@dynamic objectId;
@dynamic roomId;
@dynamic spotifyId;
@dynamic score;

+ (nonnull NSString *)parseClassName {
    return @"QueueSong";
}

+ (void)requestSongWithSpotifyId:(NSString *)spotifyId roomId:(NSString *)roomId completion:(PFBooleanResultBlock)completion {
    QueueSong *newSong = [QueueSong new];
    newSong.roomId = roomId;
    newSong.spotifyId = spotifyId;
    newSong.score = @(0);
    [newSong saveInBackgroundWithBlock:completion];
}

+ (void)getCurrentQueueSongs {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query whereKey:@"roomId" equalTo:[[ParseRoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *queueSongs, NSError *error) {
        if (queueSongs) {
            [[ParseRoomManager shared] updateQueueWithSongs:queueSongs];
        }
    }];
}

+ (void)incrementScoreForQueueSongWithId:(NSString *)queueSongId byAmount:(NSNumber *)amount {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query getObjectInBackgroundWithId:queueSongId block:^(PFObject *queueSong, NSError *error) {
        if (queueSong) {
            [queueSong incrementKey:@"score" byAmount:amount];
        }
    }];
}

- (BOOL)isUpvotedByCurrentUser {
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray<NSString *> *upvotedSongIds = [currentUser valueForKey:@"upvotedSongIds"];
    for (NSString *upvotedSongId in upvotedSongIds) {
        if ([self.objectId isEqualToString:upvotedSongId]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isDownvotedByCurrentUser {
    PFUser *currentUser = [PFUser currentUser];
    NSMutableArray<NSString *> *downvotedSongIds = [currentUser valueForKey:@"downvotedSongIds"];
    for (NSString *downvotedSongId in downvotedSongIds) {
        if ([self.objectId isEqualToString:downvotedSongId]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isUnvotedByCurrentUser {
    return ![self isUpvotedByCurrentUser] && ![self isDownvotedByCurrentUser];
}

@end
