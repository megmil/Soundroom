//
//  ParseLiveClient.m
//  Soundroom
//
//  Created by Megan Miller on 7/13/22.
//

#import "ParseLiveQueryManager.h"
#import "ParseRoomManager.h"
#import "ParseUserManager.h"
#import "Room.h"

@implementation ParseLiveQueryManager

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}


# pragma mark - Subscriptions

- (void)newSongRequestSubscription {
    PFQuery *query = [self queueSongsQuery];
    PFLiveQuerySubscription *subscription = [[self.client subscribeToQuery:query] addCreateHandler:^(PFQuery<PFObject *> *objects, PFObject *object) {
        QueueSong *queueSong = (QueueSong *)object;
        [[ParseRoomManager shared] updateQueueWithSong:queueSong]; // update room manager
    }];
}

- (void)queueSongScoreUpdateSubscription {
    PFQuery *query = [self queueSongsQuery];
    PFLiveQuerySubscription *subscription = [[self.client subscribeToQuery:query] addUpdateHandler:^(PFQuery<PFObject *> *objects, PFObject *object) {
        QueueSong *queueSong = (QueueSong *)object;
        [[ParseRoomManager shared] updateScoreForSong:queueSong];
    }];
}

- (PFQuery *)queueSongsQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"QueueSong"];
    [query whereKey:@"roomId" equalTo:[[ParseRoomManager shared] currentRoomId]]; // TODO: should update room id
    return query;
}

@end
