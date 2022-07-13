//
//  ParseLiveClient.m
//  Soundroom
//
//  Created by Megan Miller on 7/13/22.
//

#import "ParseLiveClient.h"
#import "ParseRoomManager.h"
#import "Room.h"

@implementation ParseLiveClient

+ (instancetype)shared {
    static dispatch_once_t once;
    static id shared;
    dispatch_once(&once, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

// REQUIRES: user is logged in
- (void)currentUserRoomStatus {
    
    if (!clientConfigured) {
        [self configureClient];
    }
    
    NSString *currentUserId = [PFUser currentUser].objectId;
    NSArray *currentUserIdArray = [NSArray arrayWithObject:currentUserId]; // userId != nil
    
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query whereKey:@"memberIds" containsAllObjectsInArray:currentUserIdArray];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable rooms, NSError * _Nullable error) {
        if (rooms.count > 1) {
            // TODO: multiple rooms error handling
        } else if (rooms) {
            Room *room = [rooms firstObject];
            [[ParseRoomManager shared] addCurrentUserToRoomWithId:room.objectId completion:nil];
        } else {
            NSLog(@"no rooms");
        }
    }];
    
    PFLiveQuerySubscription *subscription = [self.client subscribeToQuery:query];
    [subscription addEnterHandler:^(PFQuery<PFObject *> * _Nonnull rooms, PFObject * _Nonnull room) {
        if (rooms.countObjects != 1) {
            return;
        }
        [[ParseRoomManager shared] addCurrentUserToRoomWithId:room.objectId completion:^(BOOL succeeded, NSError * _Nullable error) {
            // TODO: completion
        }];
    }];
}

- (void)configureClient {
    
    if (!credentialsLoaded) {
        [self loadCredentials];
    }
    
    self.client = [[PFLiveQueryClient alloc] initWithServer:self.liveServer applicationId:self.appId clientKey:self.clientKey];
    clientConfigured = YES;
}

- (void)loadCredentials {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    self.liveServer = [credentials objectForKey:@"parse-live-server"];
    self.appId = [credentials objectForKey:@"parse-app-id"];
    self.clientKey = [credentials objectForKey:@"parse-client-key"];
    credentialsLoaded = YES;
}

@end
