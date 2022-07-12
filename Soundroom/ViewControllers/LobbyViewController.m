//
//  LobbyViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LobbyViewController.h"
#import "RoomViewController.h"
#import "ParseRoomManager.h"

@interface LobbyViewController ()

@end

@implementation LobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([[ParseRoomManager shared] inRoom]) {
        [self enterRoom];
    }
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterRoom) name:@"OpenRoomNotification" object:nil];
}

- (void)enterRoom {
    RoomViewController *roomVC = [[RoomViewController alloc] init];
    [self presentViewController:roomVC animated:YES completion:nil];
}

@end
