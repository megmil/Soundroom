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
}

- (void)goToLobby {
    [self dismissViewControllerAnimated:NO completion:nil]; // TODO: animate?
}

- (IBAction)leaveRoom:(id)sender {
    [[ParseRoomManager shared] removeCurrentUserWithCompletion:nil];
}

@end
