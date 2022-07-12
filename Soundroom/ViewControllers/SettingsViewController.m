//
//  SettingsViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "SettingsViewController.h"
#import "SpotifyAuthClient.h"
#import "Parse/Parse.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapUserLogout:(id)sender {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // TODO: show loginVC
    }];
}

- (IBAction)didTapSpotifyLogout:(id)sender {
    [[SpotifyAuthClient shared] signOut];
}


@end
