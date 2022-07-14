//
//  LobbyViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LobbyViewController.h"
#import "RoomViewController.h"
#import "ConfigureViewController.h"
#import "ParseLiveClient.h"
#import "ParseRoomManager.h"

@interface LobbyViewController ()

@end

@implementation LobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoom) name:@"DismissLobbyViewController" object:nil];
    [[ParseRoomManager shared] lookForCurrentRoom];
    [[ParseLiveClient shared] connect];
}

- (void)goToRoom {
    [self dismissViewControllerAnimated:NO completion:nil]; // TODO: animate?
}

@end
