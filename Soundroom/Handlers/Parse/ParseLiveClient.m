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

- (void)newInvitationSubscriber {
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query whereKey:@"memberIds" equalTo:[PFUser currentUser].objectId]; // get rooms that list currentUser as a member
    
    self.subscription = [[self.client subscribeToQuery:query] addEnterHandler:^(PFQuery<PFObject *> *rooms, PFObject *room) {
        // TODO: if invited by another user or already in a room, send notification
        if (rooms.countObjects == 1) {
            [[ParseRoomManager shared] setCurrentRoomId:room.objectId]; // update room manager
        }
    }];
}

- (void)connect {
    
    if (!clientConfigured) {
        [self configureClient];
    }
    
    [self newInvitationSubscriber];
}

- (void)configureClient {
    if (!credentialsLoaded) {
        [self loadCredentials];
    }
    self.client = [[PFLiveQueryClient alloc] initWithServer:self.server applicationId:self.appId clientKey:self.clientKey];
    clientConfigured = YES;
}

- (void)loadCredentials {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    self.server = [credentials objectForKey:@"parse-live-server"];
    self.appId = [credentials objectForKey:@"parse-app-id"];
    self.clientKey = [credentials objectForKey:@"parse-client-key"];
    credentialsLoaded = YES;
}

@end
