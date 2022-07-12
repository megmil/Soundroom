//
//  ConfigureViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "ConfigureViewController.h"
#import "Room.h"

@interface ConfigureViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleField;

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapCreateRoom:(id)sender {
    [Room createRoomWithTitle:self.titleField.text completion:^(NSString * _Nonnull roomID, NSError * _Nonnull error) {
        if (roomID) {
            NSLog(@"id: %@", roomID);
        }
    }];
}

@end
