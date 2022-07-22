//
//  LobbyViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LobbyViewController.h"
#import "RoomManager.h"

@interface LobbyViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation LobbyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goToRoom) name:RoomManagerJoinedRoomNotification object:nil];
}

- (void)goToRoom {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil]; // dismiss configureVC
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil]; // dismiss self
    });
}

@end
