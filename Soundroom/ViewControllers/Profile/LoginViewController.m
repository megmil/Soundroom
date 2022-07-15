//
//  UserLoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LoginViewController.h"
#import "ParseUserManager.h"
#import "ParseLiveQueryManager.h"
#import "SceneDelegate.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapUserLogin:(id)sender {
    
    if ([self hasEmptyField]) {
        [self showEmptyFieldAlert];
        return;
    }
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [ParseUserManager loginWithUsername:username password:password completion:^(PFUser *user, NSError *error) {
        if (user) {
            [self goToTabBar];
        }
    }];
}

- (IBAction)didTapUserRegister:(id)sender {
    
    if ([self hasEmptyField]) {
        [self showEmptyFieldAlert];
        return;
    }
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    [ParseUserManager registerWithUsername:username password:password completion:^(PFUser *user, NSError *error) {
        if (user) {
            [self goToTabBar];
        }
    }];
}

- (void)goToTabBar {
    SceneDelegate *sceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    sceneDelegate.window.rootViewController = tabBarController;
}

- (BOOL)hasEmptyField {
    return self.usernameField.text.length == 0 || self.passwordField.text.length == 0;
}

- (void)showAlertWithError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Could not perform action"
                                                                   message:error.localizedDescription
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^{
        return;
    }];
}

- (void)showEmptyFieldAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Text Field(s)"
                                                                   message:@"Please fill in username and password."
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^{
        return;
    }];
}

@end
