//
//  AccountView.m
//  Soundroom
//
//  Created by Megan Miller on 7/14/22.
//

#import "AccountView.h"
#import "ImageConstants.h"

static NSString *const soundroomName = @"Soundroom";
static NSString *const spotifyName = @"Spotify";
static NSString *const appleMusicName = @"Apple Music";
static NSString *const loggedOutName = @"Music Player";

@implementation AccountView {
    UILabel *_appLabel;
    UIImageView *_appImageView;
    UIImageView *_statusImageView;
    UIButton *_actionButton;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [_appLabel sizeToFit];
    
    const CGFloat viewWidth = self.frame.size.width;
    const CGFloat viewHeight = self.frame.size.height;
    const CGFloat padding = 8.f;
    
    const CGFloat appImageViewSize = 50.f;
    const CGFloat actionButtonSize = 25.f;
    const CGFloat statusImageViewSize = 15.f;
    
    const CGFloat centeredImageViewOriginX = (viewWidth - appImageViewSize) / 2.f;
    const CGFloat centeredImageViewOriginY = (viewHeight - appImageViewSize) / 2.f;
    
    const CGFloat appLabelWidth = _appLabel.frame.size.width;
    const CGFloat appLabelHeight = _appLabel.frame.size.height;
    const CGFloat appLabelOriginY = viewHeight - appLabelHeight - padding;
    
    const CGFloat statusImageViewOriginX = viewWidth - statusImageViewSize - padding;
    const CGFloat actionButtonOriginX = viewWidth - actionButtonSize - padding;
    const CGFloat actionButtonOriginY = viewHeight - actionButtonSize - padding;
    
    _appImageView.frame = CGRectMake(centeredImageViewOriginX, centeredImageViewOriginY, appImageViewSize, appImageViewSize);
    _appLabel.frame = CGRectMake(padding, appLabelOriginY, appLabelWidth, appLabelHeight);
    _statusImageView.frame = CGRectMake(statusImageViewOriginX, padding, statusImageViewSize, statusImageViewSize);
    _actionButton.frame = CGRectMake(actionButtonOriginX, actionButtonOriginY, actionButtonSize, actionButtonSize);
    
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    if (self) {
        
        self.layer.cornerRadius = 5;        
        [self configureAppLabel];
        [self configureAppImageView];
        [self configureStatusImageView];
        [self configureActionButton];
        
    }
    
    return self;
}

- (void)configureAppLabel {
    _appLabel = [UILabel new];
    _appLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
    _appLabel.textColor = [UIColor blackColor];
    [self addSubview:_appLabel];
}

- (void)configureAppImageView {
    _appImageView = [UIImageView new];
    _appImageView.tintColor = [UIColor blackColor];
    _appImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_appImageView];
}

- (void)configureStatusImageView {
    _statusImageView = [UIImageView new];
    _statusImageView.contentMode = UIViewContentModeScaleAspectFit;
    _statusImageView.tintColor = [UIColor blackColor];
    [self addSubview:_statusImageView];
}

- (void)configureActionButton {
    _actionButton = [UIButton new];
    _actionButton.contentMode = UIViewContentModeScaleAspectFit;
    [_actionButton addTarget:self action:@selector(didTapActionButton) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_actionButton];
}

- (void)setAccountType:(AccountType)accountType {
    
    _accountType = accountType;
    
    UIColor *const soundroomColor = [UIColor systemIndigoColor];
    UIColor *const spotifyColor = [UIColor colorWithRed:29.f/225.f green:185.f/225.f blue:84.f/225.f alpha:1.f];
    UIColor *const appleMusicColor = [UIColor systemPinkColor];
    
    BOOL isLoggedIn = (accountType != LoggedOut);
    [self setIsLoggedIn:isLoggedIn];
    
    if (accountType == Soundroom) {
        _appLabel.text = soundroomName;
        _appImageView.image = [UIImage systemImageNamed:soundroomImageName];
        self.backgroundColor = soundroomColor;
        return;
    }
    
    if (accountType == Spotify) {
        _appLabel.text = spotifyName;
        _appImageView.image = [UIImage imageNamed:spotifyImageName];
        self.backgroundColor = spotifyColor;
        return;
    }
    
    if (accountType == AppleMusic) {
        _appLabel.text = appleMusicName;
        _appImageView.image = [UIImage systemImageNamed:appleMusicImageName];
        self.backgroundColor = appleMusicColor;
        return;
    }
    
    _appLabel.text = loggedOutName;
    _appImageView.image = [UIImage systemImageNamed:loggedOutImageName];
    self.backgroundColor = soundroomColor;
    
}

- (void)setIsLoggedIn:(BOOL)isLoggedIn {
    _statusImageView.image = isLoggedIn ? [UIImage systemImageNamed:verifiedImageName] : [UIImage systemImageNamed:warningImageName];
    UIImage *actionButtonImage = isLoggedIn ? [UIImage systemImageNamed:logoutImageName] : [UIImage systemImageNamed:loginImageName];
    [_actionButton setImage:actionButtonImage forState:UIControlStateNormal];
}

- (void)didTapActionButton {
    
    // if the user is not already logged in, must be music player login
    if (_accountType == LoggedOut) {
        [self.delegate didTapMusicPlayerLogin];
        return;
    }
    
    // if this is a Soundroom account view, only action is logout
    if (_accountType == Soundroom) {
        [self.delegate didTapUserLogout];
        return;
    }
    
    [self.delegate didTapMusicPlayerLogout];
    
}

@end
