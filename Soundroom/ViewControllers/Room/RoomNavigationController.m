//
//  RoomNavigationController.m
//  Soundroom
//
//  Created by Megan Miller on 7/14/22.
//

#import "RoomNavigationController.h"
#import "LobbyViewController.h"
#import "RoomViewController.h"
#import "RoomManager.h"

@interface RoomNavigationController ()

@end

@implementation RoomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadRoomStatus];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLobby) name:RoomManagerLeftRoomNotification object:nil];
}

- (void)loadRoomStatus {
    // attempt to fetch room
    [[RoomManager shared] fetchCurrentRoomWithCompletion:^(BOOL didFindRoom, NSError *error) {
        if (!didFindRoom) {
            // if there is no room, go to lobby
            [self goToLobby];
        }
    }];
}

- (void)goToLobby {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LobbyViewController *lobbyVC = [storyboard instantiateViewControllerWithIdentifier:LobbyViewControllerIdentifier];
        [lobbyVC setModalPresentationStyle:UIModalPresentationCurrentContext];
        
        RoomViewController *roomVC = [self.viewControllers firstObject];
        [roomVC presentViewController:lobbyVC animated:YES completion:nil];
    });
}

@end
