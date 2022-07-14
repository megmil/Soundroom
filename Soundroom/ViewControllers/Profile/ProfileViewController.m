//
//  ProfileViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.usernameLabel.text = [[PFUser currentUser] valueForKey:@"username"];
}

@end
