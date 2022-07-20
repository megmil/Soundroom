//
//  ParseQueueManager.m
//  Soundroom
//
//  Created by Megan Miller on 7/19/22.
//

#import "ParseQueueManager.h"
#import "ParseRoomManager.h"
#import "Vote.h"

@implementation ParseQueueManager

+ (NSNumber *)scoreForSongWithId:(NSString *)songId {
    
    double __block score = 0;
    NSString *roomId = [[ParseRoomManager shared] currentRoomId];
    
    if (roomId) {
        PFQuery *query = [PFQuery queryWithClassName:@"Vote"];
        [query whereKey:@"songId" equalTo:songId];
        [query whereKey:@"roomId" equalTo:roomId];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (objects) {
                for (Vote *vote in objects) {
                    score += [vote.increment doubleValue];
                }
            }
        }];
    }
    
    NSNumber *finalScore = [NSNumber numberWithDouble:score];
    return finalScore;
    
}

@end
