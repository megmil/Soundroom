//
//  LoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/7/22.
//

#import "LoginViewController.h"
#import "SpotifyAuthClient.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapLogin:(id)sender {
    [[SpotifyAuthClient sharedInstance] authenticateInViewController:self];
}

@end
