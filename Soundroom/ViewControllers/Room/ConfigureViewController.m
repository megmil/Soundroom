//
//  ConfigureViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "ConfigureViewController.h"
#import "ConfigureView.h"
#import "ParseObjectManager.h"

@interface ConfigureViewController () <ConfigureViewDelegate>

@property (strong, nonatomic) IBOutlet ConfigureView *configureView;

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.configureView.delegate = self;
}

- (void)createRoom {
    [ParseObjectManager createRoomWithTitle:_configureView.title listeningMode:_configureView.listeningMode];
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
