//
//  LobbyViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LobbyViewController.h"
#import "RoomViewController.h"
#import "ConfigureViewController.h"
#import "ParseRoomManager.h"

@interface LobbyViewController ()

@end

@implementation LobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoom) name:ParseRoomManagerJoinedRoomNotification object:nil];
}

- (void)goToRoom {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil]; // dismiss self
}

@end
