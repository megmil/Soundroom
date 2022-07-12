//
//  ConfigureViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/11/22.
//

#import "ConfigureViewController.h"
#import "SNDRoom.h"

@interface ConfigureViewController ()

@property (weak, nonatomic) IBOutlet UITextField *titleField;

@end

@implementation ConfigureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)didTapCreate:(id)sender {
    // TODO
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [SNDRoom createRoomWithTitle:self.titleField.text];
}

@end
