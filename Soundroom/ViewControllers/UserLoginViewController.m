//
//  UserLoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "UserLoginViewController.h"
#import "RealmAccountManager.h"

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
    [[RealmAccountManager shared] registerWithUsername:username password:password completion:^(NSError * _Nonnull error) {
        if (!error) {
            [self loginWithUsername:username password:password];
        } else {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password {
    [[RealmAccountManager shared] loginWithUsername:username password:password completion:^(RLMUser * _Nullable user, NSError * _Nullable error) {
        if (!error) {
            // TODO: segue to tabbar
        }
    }];
}

- (BOOL)isFieldEmpty {
    return [self.usernameField.text isEqual:@""] || [self.passwordField.text isEqual:@""];
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
