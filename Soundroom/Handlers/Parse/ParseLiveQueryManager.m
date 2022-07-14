//
//  ParseLiveClient.m
//  Soundroom
//
//  Created by Megan Miller on 7/13/22.
//

#import "ParseLiveQueryManager.h"
#import "ParseRoomManager.h"
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

# pragma mark - Public

- (void)connect {
    if (!clientConfigured) {
        [self configureClient];
    }
    [self newInvitationSubcription];
    [self leaveRoomSubscription];
}


# pragma mark - Subscriptions

- (void)newInvitationSubcription {
    PFQuery *query = [self currentRoomsQuery];
    PFLiveQuerySubscription *subscription = [[self.client subscribeToQuery:query] addEnterHandler:^(PFQuery<PFObject *> *rooms, PFObject *room) {
        if (rooms.countObjects == 1) {
            [[ParseRoomManager shared] setCurrentRoomId:room.objectId]; // update room manager
        }
    }];
}

- (void)leaveRoomSubscription {
    PFQuery *query = [self currentRoomsQuery];
    PFLiveQuerySubscription *subscription = [[self.client subscribeToQuery:query] addLeaveHandler:^(PFQuery<PFObject *> *rooms, PFObject *room) {
        [[ParseRoomManager shared] resetCurrentRoomId]; // update room manager
    }];
}

# pragma mark - Client

- (void)configureClient {
    if (!credentialsLoaded) {
        [self loadCredentials];
    }
    self.client = [[PFLiveQueryClient alloc] initWithServer:self.server applicationId:self.appId clientKey:self.clientKey];
    clientConfigured = YES;
}

# pragma mark - Helpers

- (void)loadCredentials {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    self.server = [credentials objectForKey:@"parse-live-server"];
    self.appId = [credentials objectForKey:@"parse-app-id"];
    self.clientKey = [credentials objectForKey:@"parse-client-key"];
    credentialsLoaded = YES;
}

- (PFQuery *)currentRoomsQuery {
    PFQuery *query = [PFQuery queryWithClassName:@"Room"];
    [query whereKey:@"memberIds" equalTo:[PFUser currentUser].objectId]; // get rooms that list currentUser as a member
    return query;
}

@end
