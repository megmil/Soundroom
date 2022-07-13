//
//  ConfigureViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "ConfigureViewController.h"
#import "ParseRoomManager.h"
#import "ConfigureView.h"
#import "SearchViewController.h"

@interface ConfigureViewController () <ConfigureViewDelegate>

@property (strong, nonatomic) IBOutlet ConfigureView *configureView;

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.configureView.delegate = self;
}

- (void)createRoom {
    [[ParseRoomManager shared] createRoomWithTitle:self.configureView.title
                                        completion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"OpenedRoom" object:self];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }];
}

- (void)inviteMembers {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SearchViewController *searchVC = [storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    searchVC.isUserSearch = YES;
    [self presentViewController:searchVC animated:YES completion:nil];
}

@end
