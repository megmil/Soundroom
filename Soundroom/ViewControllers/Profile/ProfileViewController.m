//
//  ProfileViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "ProfileViewController.h"
#import "AccountView.h"
#import "SpotifySessionManager.h"
#import "ParseUserManager.h"
#import "SceneDelegate.h"
#import "ImageConstants.h"
#import "LoginViewController.h"

static const CGFloat cornerRadiusRatio = 0.06f;

@interface ProfileViewController () <AccountViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet AccountView *soundroomAccountView;
@property (weak, nonatomic) IBOutlet AccountView *spotifyAccountView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self configureUserViews];
    [self configureAccountViews];
    [self configureObservers];
    
}

- (void)configureUserViews {
    _usernameLabel.text = [ParseUserManager currentUsername];
    _avatarImageView.image = [ParseUserManager avatarImageForCurrentUser];
    _avatarImageView.layer.cornerRadius = CGRectGetWidth(_avatarImageView.frame) * cornerRadiusRatio;
    _avatarImageView.layer.masksToBounds = YES;
}

- (void)configureAccountViews {
    
    _soundroomAccountView.isUserAccountView = YES;
    _soundroomAccountView.isLoggedIn = YES;
    _soundroomAccountView.delegate = self;
    
    _spotifyAccountView.isUserAccountView = NO;
    _spotifyAccountView.isLoggedIn = [[SpotifySessionManager shared] isSessionAuthorized];
    _spotifyAccountView.delegate = self;
    
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSpotifyLoginStatus) name:SpotifySessionManagerAuthorizedNotificaton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSpotifyLoginStatus) name:SpotifySessionManagerDeauthorizedNotificaton object:nil];
}

- (void)didTapSpotifyLogin {
    [[SpotifySessionManager shared] authorizeSession];
}

- (void)didTapSpotifyLogout {
    [[SpotifySessionManager shared] signOut];
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
    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:LoginViewControllerIdentifier];
    sceneDelegate.window.rootViewController = loginVC;
}

- (void)toggleSpotifyLoginStatus {
    _spotifyAccountView.isLoggedIn = [[SpotifySessionManager shared] isSessionAuthorized];
}

@end
