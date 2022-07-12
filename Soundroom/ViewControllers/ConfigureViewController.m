//
//  ConfigureViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "ConfigureViewController.h"
#import "ParseRoomManager.h"

@interface ConfigureViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleField;

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapCreateRoom:(id)sender {
    [[ParseRoomManager shared] createRoomWithTitle:self.titleField.text completion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [self dismissViewControllerAnimated:NO completion:nil];
        } else {
            NSLog(@"error: %@", error);
        }
    }];
}

@end
