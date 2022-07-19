//
//  ProfileViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "ProfileViewController.h"
#import "Parse/Parse.h"
#import "AccountView.h"
#import "SpotifyRemoteManager.h"
#import "ParseUserManager.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"

@interface ProfileViewController () <AccountViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet AccountView *soundroomAccountView;
@property (weak, nonatomic) IBOutlet AccountView *spotifyAccountView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.usernameLabel.text = [[PFUser currentUser] valueForKey:@"username"];
    
    self.soundroomAccountView.isUserAccountView = YES;
    self.soundroomAccountView.isLoggedIn = YES;
    self.soundroomAccountView.delegate = self;
    
    self.spotifyAccountView.isUserAccountView = NO;
    self.spotifyAccountView.isLoggedIn = [[SpotifyRemoteManager shared] isAuthorized];
    self.spotifyAccountView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSpotifyLoginStatus) name:SpotifyRemoteManagerConnectedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSpotifyLoginStatus) name:SpotifyRemoteManagerDisconnectedNotification object:nil];
}

- (void)didTapSpotifyLogin {
    [[SpotifyRemoteManager shared] authorizeSession];
}

- (void)didTapSpotifyLogout {
    [[SpotifyRemoteManager shared] signOut];
}

- (void)didTapUserLogout {
    [ParseUserManager logoutWithCompletion:^(NSError *error) {
        if (!error) {
            [self goToLogin];
        }
    }];
}

- (void)goToLogin {
    SceneDelegate *sceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    sceneDelegate.window.rootViewController = loginVC;
}

- (void)toggleSpotifyLoginStatus {
    self.spotifyAccountView.isLoggedIn = !self.spotifyAccountView.isLoggedIn;
    //[[SpotifyRemoteManager shared] pausePlayback];
}

@end
