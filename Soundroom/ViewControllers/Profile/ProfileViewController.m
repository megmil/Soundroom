//
//  ProfileViewController.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "ProfileViewController.h"
#import "AccountView.h"
#import "MusicPlayerManager.h"
#import "ParseUserManager.h"
#import "SceneDelegate.h"
#import "ImageConstants.h"
#import "LoginViewController.h"
#import "RoomCell.h"
#import "UITableView+ReuseIdentifier.h"
#import "UITableView+EmptyMessage.h"

static NSString *const emptyTableMessage = @"No recent sessions to show.";
static const CGFloat cornerRadiusRatio = 0.06f;

@interface ProfileViewController () <AccountViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet AccountView *soundroomAccountView;
@property (weak, nonatomic) IBOutlet AccountView *spotifyAccountView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[RoomCell class] forCellReuseIdentifier:[RoomCell reuseIdentifier]];
    _tableView.layer.borderWidth = 1.8f;
    _tableView.layer.borderColor = [UIColor tertiarySystemBackgroundColor].CGColor;
    
}

- (void)configureAccountViews {
    
    _soundroomAccountView.isUserAccountView = YES;
    _soundroomAccountView.isLoggedIn = YES;
    _soundroomAccountView.delegate = self;
    
    _spotifyAccountView.isUserAccountView = NO;
    _spotifyAccountView.isLoggedIn = [[MusicPlayerManager shared] isSessionAuthorized];
    _spotifyAccountView.delegate = self;
    
}

- (void)configureObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSpotifyLoginStatus) name:MusicPlayerManagerAuthorizedNotificaton object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toggleSpotifyLoginStatus) name:MusicPlayerManagerDeauthorizedNotificaton object:nil];
}

# pragma mark - AccountView

- (void)didTapSpotifyLogin {
    [[MusicPlayerManager shared] authorizeSession];
}

- (void)didTapSpotifyLogout {
    [[MusicPlayerManager shared] signOut];
}

- (void)didTapUserLogout {
    [ParseUserManager logoutWithCompletion:^(NSError *error) {
        if (!error) {
            [self goToLogin];
        }
    }];
}

# pragma mark - TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [_tableView showEmptyMessageWithText:emptyTableMessage];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:[RoomCell reuseIdentifier]];
    return cell;
}

# pragma mark - Helpers

- (void)goToLogin {
    SceneDelegate *sceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginViewController *loginVC = [storyboard instantiateViewControllerWithIdentifier:LoginViewControllerIdentifier];
    sceneDelegate.window.rootViewController = loginVC;
}

- (void)toggleSpotifyLoginStatus {
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self->_spotifyAccountView.isLoggedIn = [[MusicPlayerManager shared] isSessionAuthorized];
    });
}

@end
