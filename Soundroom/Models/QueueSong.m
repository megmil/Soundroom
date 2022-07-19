//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"

@implementation QueueSong

@dynamic objectId;
@dynamic roomId;
@dynamic spotifyId;
@dynamic spotifyURI;
@dynamic score;

+ (nonnull NSString *)parseClassName {
    return @"QueueSong";
}

+ (void)requestSongWithSpotifyId:(NSString *)spotifyId spotifyURI:(NSString *)spotifyURI roomId:(NSString *)roomId completion:(PFBooleanResultBlock)completion {
    QueueSong *newSong = [QueueSong new];
    newSong.roomId = roomId;
    newSong.spotifyId = spotifyId;
    newSong.spotifyURI = spotifyURI;
    newSong.score = @(0);
    [newSong saveInBackgroundWithBlock:completion];
}

+ (void)incrementScoreForQueueSongWithId:(NSString *)queueSongId byAmount:(NSNumber *)amount {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query getObjectInBackgroundWithId:queueSongId block:^(PFObject *queueSong, NSError *error) {
        if (queueSong) {
            [queueSong incrementKey:@"score" byAmount:amount];
            [queueSong saveInBackground];
        }
    }];
}

+ (void)deleteAllQueueSongsWithRoomId:(NSString *)roomId {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query whereKey:@"roomId" equalTo:roomId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (PFObject *object in objects) {
            [object deleteEventually];
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

- (BOOL)isNotVotedByCurrentUser {
    return ![self isUpvotedByCurrentUser] && ![self isDownvotedByCurrentUser];
}

@end
