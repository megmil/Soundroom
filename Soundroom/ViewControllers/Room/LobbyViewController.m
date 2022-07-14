//
//  LobbyViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LobbyViewController.h"
#import "RoomViewController.h"
#import "ConfigureViewController.h"
#import "ParseLiveQueryManager.h"
#import "ParseRoomManager.h"

@interface LobbyViewController ()

@end

@implementation LobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoom) name:@"DismissLobbyViewController" object:nil];
    [[ParseRoomManager shared] lookForCurrentRoom];
    [[ParseLiveQueryManager shared] connect];
}

- (void)goToRoom {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RoomViewController *lobbyVC = [storyboard instantiateViewControllerWithIdentifier:@"LobbyViewController"];
    [lobbyVC setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:lobbyVC animated:NO completion:nil];
}

@end
