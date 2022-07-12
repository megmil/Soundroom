//
//  UserLoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "UserLoginViewController.h"
#import "Parse/Parse.h"

@interface UserLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;

@end

@implementation UserLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapUserLogin:(id)sender {
    
    if ([self isFieldEmpty]) {
        [self showEmptyFieldAlert];
        return;
    }
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    [self loginWithUsername:username password:password];
}

- (IBAction)didTapUserRegister:(id)sender {
    
    if ([self isFieldEmpty]) {
        [self showEmptyFieldAlert];
        return;
    }
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    [self registerWithUsername:username password:password];
}

- (void)registerWithUsername:(NSString *)username password:(NSString *)password {
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self loginWithUsername:username password:password];
        }
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (!error) {
            // TODO: perform segue
        }
    }];
}

- (BOOL)isFieldEmpty {
    return [self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""];
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
