//
//  UserLoginViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "UserLoginViewController.h"
#import "Realm/Realm.h"

@interface UserLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (strong, nonatomic) UIAlertController *alert;

@end

@implementation UserLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureAlert];
}

- (IBAction)didTapUserLogin:(id)sender {
    if ([self isFieldEmpty]) {
        [self showAlert];
    } else {
        NSString *email = self.emailField.text;
        NSString *password = self.passwordField.text;
        
        
    }
}

- (IBAction)didTapUserRegister:(id)sender {
    if ([self isFieldEmpty]) {
        [self showAlert];
    } else {
        
    }
}

- (BOOL)isFieldEmpty {
    return [self.emailField.text isEqual:@""] || [self.passwordField.text isEqual:@""];
}

- (void)showAlert {
    [self presentViewController:self.alert animated:YES completion:^{
        return;
    }];
}

- (void)configureAlert {
    self.alert = [UIAlertController alertControllerWithTitle:@"Missing Text Field(s)"
                                                                   message:@"Please fill in username and password."
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Ok"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
    }];
    [self.alert addAction:action];
}

@end
