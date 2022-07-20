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
#import "CurrentRoomManager.h"
@import ParseLiveQuery;

@interface RoomNavigationController ()

@property (strong, nonatomic) PFLiveQueryClient *client;
@property (strong, nonatomic) PFLiveQuerySubscription *subscription;

@end

@implementation RoomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // prepare to switch view controllers if the current user leaves a room
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLobby) name:ParseRoomManagerLeftRoomNotification object:nil];
    
    // check to see if the current user is already in a room
    [Room getCurrentRoomWithCompletion:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            [self goToLobby]; // if not, go to lobby
        }
    }];
    
    // setup Live Query client
    [self configureClient];
    [self configureLiveSubscriptions];
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

- (void)configureLiveSubscriptions {
    
    PFQuery *query = [self currentRoomsQuery];
    self.subscription = [self.client subscribeToQuery:query];
    
    // room that matches query is created
    [self.subscription addCreateHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[ParseRoomManager shared] setCurrentRoomId:object.objectId];
    }];
    
    // room enters query
    [self.subscription addEnterHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[ParseRoomManager shared] setCurrentRoomId:object.objectId];
    }];
    
    // room leaves query
    [self.subscription addLeaveHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[CurrentRoomManager shared] reset];
    }];
    
    // room is deleted
    [self.subscription addDeleteHandler:^(PFQuery<PFObject *> *query, PFObject *object) {
        [[CurrentRoomManager shared] reset];
    }];
    
}

- (void)configureClient {
    if (!credentialsLoaded) {
        [self loadCredentials];
    }
    self.client = [[PFLiveQueryClient alloc] initWithServer:self.server applicationId:self.appId clientKey:self.clientKey];
}

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
    [query whereKey:@"memberIds" equalTo:[ParseUserManager currentUserId]]; // get rooms that list currentUser as a member
    return query;
}

@end
