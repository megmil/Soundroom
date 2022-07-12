//
//  QueueSong.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "QueueSong.h"
#import "ParseUserManager.h"

@implementation QueueSong

+ (void)queueSongWithSpotifyId:(NSString *)spotifyId completion:(void(^)(BOOL succeeded, NSError *error))completion {
    QueueSong *newQueueSong = [QueueSong new];
    
    newQueueSong.spotifyId = spotifyId;
    newQueueSong.score = 0;
    
    // TODO: add to room manager
    if ([[ParseUserManager shared] currentUserIsInRoom]) {
        NSString *roomId = [[ParseUserManager shared] currentUserRoomId];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Room"];
        [query getObjectInBackgroundWithId:roomId block:^(PFObject * _Nullable room, NSError * _Nullable error) {
            if (room) {
                [room addObject:newQueueSong forKey:@"queue"];
                [room saveInBackgroundWithBlock:completion];
            }
        }];
    }
}

@end
