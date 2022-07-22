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
#import "ParseQueryManager.h"
#import "RoomManager.h"
#import "Invitation.h"
@import ParseLiveQuery;

@interface RoomNavigationController ()

@end

@implementation RoomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRoomStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLobby) name:RoomManagerLeftRoomNotification object:nil];
}

- (void)loadRoomStatus {
    
    [[RoomManager shared] fetchCurrentRoom];
    
    // check if room was fetched
    if (![[RoomManager shared] isInRoom]) {
        // if not, go to lobby
        [self goToLobby];
    }
    
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

- (void)loadCredentials {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Keys" ofType:@"plist"];
    NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    _server = [credentials objectForKey:@"parse-live-server"];
    _appId = [credentials objectForKey:@"parse-app-id"];
    _clientKey = [credentials objectForKey:@"parse-client-key"];
    didLoadCredentials = YES;
}

@end
