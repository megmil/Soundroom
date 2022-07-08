//
//  LoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/7/22.
//

#import "LoginViewController.h"
#import "OAuth2Client.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapLogin:(id)sender {
    [[OAuth2Client sharedInstance] authenticateInViewController:self];
    NSLog(@"%@", [[OAuth2Client sharedInstance] signedIn]);
}

@end
