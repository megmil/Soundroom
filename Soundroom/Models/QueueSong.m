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

+ (void)getCurrentQueueSongsWithCompletion:(PFArrayResultBlock)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query whereKey:@"roomId" equalTo:[[ParseRoomManager shared] currentRoomId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *queueSongs, NSError *error) {
        if (queueSongs) {
            [[ParseRoomManager shared] updateQueueWithSongs:queueSongs];
        }
        completion(queueSongs, error);
    }];
}

@end
