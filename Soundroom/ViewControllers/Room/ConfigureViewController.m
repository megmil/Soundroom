//
//  ConfigureViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "ConfigureViewController.h"
#import "ConfigureView.h"
#import "Room.h"

@interface ConfigureViewController () <ConfigureViewDelegate>

@property (strong, nonatomic) IBOutlet ConfigureView *configureView;

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.configureView.delegate = self;
}

- (void)createRoom {
    [Room createRoomWithTitle:self.configureView.title completion:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DismissLobbyViewController" object:self]; // TODO: replace with liveQuery observer
            [self dismissViewControllerAnimated:NO completion:nil]; // TODO: required?
        }
    }];
}

- (void)inviteMembers {
    /*
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    searchVC.isUserSearch = YES;
    [self presentViewController:searchVC animated:YES completion:nil];
     */
}

@end
