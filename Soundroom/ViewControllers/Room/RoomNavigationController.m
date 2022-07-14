//
//  RoomNavigationController.m
//  Soundroom
//
//  Created by Megan Miller on 7/14/22.
//

#import "RoomNavigationController.h"
#import "LobbyViewController.h"
#import "RoomViewController.h"
#import "ParseRoomManager.h"
#import "ParseLiveQueryManager.h"

@interface RoomNavigationController ()

@end

@implementation RoomNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // prepare to switch view controllers if the current user leaves or joins a room
    [[ParseLiveQueryManager shared] connect];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoom) name:ParseRoomManagerJoinedRoomNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToLobby) name:ParseRoomManagerLeftRoomNotification object:nil];
    
    // check to see if the current user is already in a room
    [[ParseRoomManager shared] lookForCurrentRoomWithCompletion:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            [self goToLobby]; // if not, go to lobby
        }
    }];
}

- (void)goToRoom {
    [self popToRootViewControllerAnimated:YES];
}

- (void)goToLobby {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LobbyViewController *lobbyVC = [storyboard instantiateViewControllerWithIdentifier:@"LobbyViewController"];
    [lobbyVC setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    RoomViewController *rootVC = [self.viewControllers firstObject];
    [rootVC presentViewController:lobbyVC animated:YES completion:nil];
}

@end
