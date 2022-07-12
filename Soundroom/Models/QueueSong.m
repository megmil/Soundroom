//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"
#import "ParseUserManager.h"

@implementation QueueSong

@dynamic queueSongId;
@dynamic spotifyId;
@dynamic score;

+ (nonnull NSString *)parseClassName {
    return @"QueueSong";
}

+ (void)queueSongWithSpotifyId:(NSString *)spotifyId completion:(void(^)(NSError *error))completion {
    QueueSong *newQueueSong = [QueueSong new];
    newQueueSong.spotifyId = spotifyId;
    newQueueSong.score = 0;
}

+ (void)addSong:(Song *)song completion:(PFBooleanResultBlock _Nullable)completion {
    
    QueueSong *queueSong = [QueueSong new];
    queueSong.song = song;
    queueSong.score = 0;
    
    PFUser *currentUser = [PFUser currentUser];
    queueSong.requesterAvatarImageFile = [currentUser valueForKey:@"avatarImageFile"];
    
    NSString *roomId = [currentUser valueForKey:@"roomId"];
    if (roomId) {
        PFQuery *query = [PFQuery queryWithClassName:@"Room"];
        [query getObjectInBackgroundWithId:roomId block:^(PFObject * _Nullable room, NSError * _Nullable error) {
            if (room) {
                [room addObject:queueSong forKey:@"queue"];
                [room saveInBackgroundWithBlock:completion];
            }
        }];
    }
}

@end
