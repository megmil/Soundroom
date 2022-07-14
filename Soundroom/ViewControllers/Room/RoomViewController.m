//
//  RoomViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomViewController.h"
#import "LobbyViewController.h"
#import "ParseRoomManager.h"

@interface RoomViewController ()

@end

@implementation RoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (![[ParseRoomManager shared] currentRoomExists]) {
        [self goToLobby];
    }
}

- (void)goToLobby {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RoomViewController *lobbyVC = [storyboard instantiateViewControllerWithIdentifier:@"LobbyViewController"];
    [lobbyVC setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:lobbyVC animated:NO completion:nil];
}

@end
