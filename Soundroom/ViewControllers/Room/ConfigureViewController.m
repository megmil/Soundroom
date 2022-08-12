//
//  ConfigureViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "ConfigureViewController.h"
#import "ConfigureView.h"
#import "ParseObjectManager.h"

@interface ConfigureViewController () <ConfigureViewDelegate>

@property (strong, nonatomic) IBOutlet ConfigureView *configureView;

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupConfigureView];
}

- (void)setupConfigureView {
    _configureView.enabled = YES;
    _configureView.delegate = self;
}

- (void)didTapCreate {
    
    if (_configureView.title == nil || _configureView.title.length == 0) {
        [self missingFieldAlert];
        return;
    }
    
    _configureView.enabled = NO;
    [ParseObjectManager createRoomWithTitle:_configureView.title listeningMode:_configureView.listeningMode];
    
}

- (IBAction)didTapScreen:(id)sender {
    [self.view endEditing:YES];
}

- (void)missingFieldAlert {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"Missing Field"
                                message:@"Please input a room name."
                                preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *action = [UIAlertAction
                             actionWithTitle:@"Ok"
                             style:UIAlertActionStyleCancel
                             handler:^(UIAlertAction *action) { }];
    
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:^{ return; }];
}

@end
