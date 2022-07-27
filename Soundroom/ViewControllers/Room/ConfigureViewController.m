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

- (void)didTapCreate {
    [ParseObjectManager createRoomWithTitle:_configureView.title listeningMode:_configureView.listeningMode];
}

- (void)didTapInvite {
    // TODO: show searchVC, save invited users, then invite after room is created
}

@end
