//
//  UserLoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LoginViewController.h"
#import "ParseUserManager.h"
#import "SceneDelegate.h"

NSString *const LoginViewControllerIdentifier = @"LoginViewController";

static NSString *const emptyErrorMessage = @"";
static NSString *const missingFieldsErrorMessage = @"Please fill in both username and password.";

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _errorLabel.text = emptyErrorMessage;
}

- (IBAction)didTapUserLogin:(id)sender {
    
    if ([self hasEmptyField]) {
        _errorLabel.text = missingFieldsErrorMessage;
        return;
    }
    
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    
    [ParseUserManager loginWithUsername:username password:password completion:^(PFUser *user, NSError *error) {
        
        if (user) {
            [self goToTabBar];
            return;
        }
        
        if (error) {
            self->_errorLabel.text = error.localizedDescription;
        }
        
    }];
}

- (IBAction)didTapUserRegister:(id)sender {
    
    if ([self hasEmptyField]) {
        _errorLabel.text = missingFieldsErrorMessage;
        return;
    }
    
    NSString *username = _usernameField.text;
    NSString *password = _passwordField.text;
    
    [ParseUserManager registerWithUsername:username password:password completion:^(PFUser *user, NSError *error) {
        
        if (user) {
            [self goToTabBar];
            return;
        }
        
        if (error) {
            self->_errorLabel.text = error.localizedDescription;
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
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Could not perform action"
                                message:error.localizedDescription
                                preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action) { }];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^{ return; }];
}

- (IBAction)didTapScreen:(id)sender {
    [self.view endEditing:YES];
}

@end
