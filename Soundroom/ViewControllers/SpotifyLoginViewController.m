//
//  SpotifyLoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "SpotifyLoginViewController.h"
#import "SpotifyAuthClient.h"

@interface SpotifyLoginViewController ()

@end

@implementation SpotifyLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapSpotifyLogin:(id)sender {
    [[SpotifyAuthClient shared] authenticateInViewController:self];
}

@end
