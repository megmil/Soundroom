//
//  SettingsViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "SettingsViewController.h"
#import "RealmAccountManager.h"
#import "SpotifyAuthClient.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapUserLogout:(id)sender {
    [[RealmAccountManager shared] logoutWithCompletion:^(NSError * _Nonnull error) {
        // TODO: segue to login VC
    }];
}

- (IBAction)didTapSpotifyLogout:(id)sender {
    [[SpotifyAuthClient shared] signOut];
}


@end
