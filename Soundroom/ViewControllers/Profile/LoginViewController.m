//
//  UserLoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "LoginViewController.h"
#import "ParseUserManager.h"
#import "SceneDelegate.h"
#import "UIView+TapAnimation.h"

NSString *const LoginViewControllerIdentifier = @"LoginViewController";
static NSString *const TabBarControllerIdentifier = @"TabBarController";
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
    _errorLabel.text = @"";
}

- (IBAction)didTapUserLogin:(id)sender {
    
    [_loginButton animateWithCompletion:^{
        
        if ([self hasEmptyField]) {
            self->_errorLabel.text = missingFieldsErrorMessage;
            return;
        }
        
        NSString *username = self->_usernameField.text;
        NSString *password = self->_passwordField.text;
        
        [ParseUserManager loginWithUsername:username password:password completion:^(PFUser *user, NSError *error) {
            [self handleCompletionWithUser:user error:error];
        }];
        
    }];

}

- (IBAction)didTapUserRegister:(id)sender {
    
    [_registerButton animateWithCompletion:^{
        
        if ([self hasEmptyField]) {
            self->_errorLabel.text = missingFieldsErrorMessage;
            return;
        }
        
        NSString *username = self->_usernameField.text;
        NSString *password = self->_passwordField.text;
        
        [ParseUserManager registerWithUsername:username password:password completion:^(PFUser *user, NSError *error) {
            [self handleCompletionWithUser:user error:error];
        }];
        
    }];
    
}

- (void)handleCompletionWithUser:(PFUser *)user error:(NSError *)error {
    
    if (user != nil) {
        [self goToTabBar];
        return;
    }
    
    if (error != nil) {
        self->_errorLabel.text = error.localizedDescription;
    }
    
}

- (void)goToTabBar {
    SceneDelegate *sceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:TabBarControllerIdentifier];
    sceneDelegate.window.rootViewController = tabBarController;
}

- (BOOL)hasEmptyField {
    return _usernameField.text.length == 0 || _passwordField.text.length == 0;
}

- (IBAction)didTapScreen:(id)sender {
    [self.view endEditing:YES];
}

@end
