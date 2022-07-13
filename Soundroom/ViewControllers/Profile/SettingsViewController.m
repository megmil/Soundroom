//
//  SettingsViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "SettingsViewController.h"
#import "SpotifyAuthClient.h"
#import "ParseUserManager.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapUserLogout:(id)sender {
    [[ParseUserManager shared] logoutWithCompletion:^(NSError * _Nullable error) {
        // TODO: show loginVC
    }];
}

- (IBAction)didTapSpotifyLogout:(id)sender {
    [[SpotifyAuthClient shared] signOut];
}


@end
