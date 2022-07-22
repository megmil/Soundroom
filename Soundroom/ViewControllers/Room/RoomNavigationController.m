//
//  RoomNavigationController.m
//  Soundroom
//
//  Created by Megan Miller on 7/14/22.
//

#import "RoomNavigationController.h"
#import "LobbyViewController.h"
#import "RoomViewController.h"
#import "ParseUserManager.h"
#import "RoomManager.h"
#import "InvitationManager.h"
#import "QueryManager.h"
#import "Invitation.h"
@import ParseLiveQuery;

@interface RoomNavigationController ()

@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *subscription;

@end

@implementation RoomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRoomStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLobby) name:RoomManagerLeftRoomNotification object:nil];
    [self configureLiveClient];
}

- (void)loadRoomStatus {
    
    [[RoomManager shared] fetchCurrentRoom];
    
    // check if room was fetched
    if (![[RoomManager shared] isInRoom]) {
        // if not, go to lobby
        [self goToLobby];
    }
    
}

- (void)configureLiveClient {
    if (!didLoadCredentials) {
        [self loadCredentials];
    }
    _client = [[PFLiveQueryClient alloc] initWithServer:_server applicationId:_appId clientKey:_clientKey];
    [self configureInvitationSubscriptions];
}

- (void)goToLobby {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LobbyViewController *lobbyVC = [storyboard instantiateViewControllerWithIdentifier:@"LobbyViewController"];
        [lobbyVC setModalPresentationStyle:UIModalPresentationCurrentContext];
        
        RoomViewController *roomVC = [self.viewControllers firstObject];
        [roomVC presentViewController:lobbyVC animated:YES completion:nil];
    });
}

- (void)configureInvitationSubscriptions {
    
    // reset subscriptions
    _subscription = nil;
    
    // get query for invitations accepted by current user
    PFQuery *query = [QueryManager queryForInvitationsAcceptedByCurrentUser];
    _subscription = [_client subscribeToQuery:query];
    
    // accepted invitation is created (current user created room)
    _subscription = [_subscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Invitation *invitation = (Invitation *)object;
        [[RoomManager shared] joinRoomWithId:invitation.roomId];
    }];
    
    // pending invitation is accepted (current user accepted invite)
    _subscription = [_subscription addUpdateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        Invitation *invitation = (Invitation *)object;
        [[RoomManager shared] joinRoomWithId:invitation.roomId];
    }];
    
    // accepted invitation is deleted
    _subscription = [_subscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[RoomManager shared] leaveCurrentRoom];
    }];
    
}

- (void)loadCredentials {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    _server = [credentials objectForKey:@"parse-live-server"];
    _appId = [credentials objectForKey:@"parse-app-id"];
    _clientKey = [credentials objectForKey:@"parse-client-key"];
    didLoadCredentials = YES;
}

@end
