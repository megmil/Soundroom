//
//  AccountView.m
//  Soundroom
//
//  Created by Megan Miller on 7/14/22.
//

#import "AccountView.h"

@implementation AccountView {
    UILabel *_appLabel;
    UIImageView *_appImageView;
    UIImageView *_statusImageView;
    UIButton *_actionButton;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat halfWidth = self.frame.size.width / 2;
    CGFloat halfHeight = self.frame.size.height / 2;
    
    [_appLabel sizeToFit];
    _appLabel.frame = CGRectMake(8.f, self.frame.size.height - _appLabel.frame.size.height - 8.f, _appLabel.frame.size.width, _appLabel.frame.size.height);
    _appImageView.frame = CGRectMake(halfWidth - 25.f, halfHeight - 25.f, 50.f, 50.f);
    _statusImageView.frame = CGRectMake(self.frame.size.width - 20.f - 8.f, 8.f, 20.f, 20.f);
    _actionButton.frame = CGRectMake(self.frame.size.width - 25.f - 8.f, self.frame.size.height - 25.f - 8.f, 25.f, 25.f);
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    if (self) {
        self.layer.cornerRadius = 5;
        
        _appLabel = [UILabel new];
        _appLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightMedium];
        _appLabel.numberOfLines = 1;
        [self addSubview:_appLabel];
        
        _appImageView = [UIImageView new];
        _appImageView.tintColor = [UIColor blackColor];
        [self addSubview:_appImageView];
        
        _statusImageView = [UIImageView new];
        _statusImageView.tintColor = [UIColor blackColor];
        [self addSubview:_statusImageView];
        
        _actionButton = [UIButton new];
        [_actionButton addTarget:self action:@selector(didTapActionButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_actionButton];
    }
    
    return self;
}

- (void)setIsUserAccountView:(BOOL)isUserAccountView {
    _isUserAccountView = isUserAccountView;
    if (isUserAccountView) {
        _appLabel.text = @"Soundroom";
        _appImageView.image = [UIImage systemImageNamed:@"music.note"];
        return;
    }
    _appLabel.text = @"Spotify";
    _appImageView.image = [UIImage systemImageNamed:@"music.mic.circle"];
}

- (void)setIsLoggedIn:(BOOL)isLoggedIn {
    _isLoggedIn = isLoggedIn;
    if (isLoggedIn) {
        _statusImageView.image = [UIImage systemImageNamed:@"checkmark.circle"];
        [_actionButton setImage:[UIImage systemImageNamed:@"rectangle.portrait.and.arrow.right"] forState:UIControlStateNormal];
        return;
    }
    _statusImageView.image = [UIImage systemImageNamed:@"exclamationmark.triangle"];
    [_actionButton setImage:[UIImage systemImageNamed:@"person.fill"] forState:UIControlStateNormal];
}

- (void)didTapActionButton {
    
    // if the user is not already logged in, must be spotify login
    if (!self.isLoggedIn) {
        [self.delegate didTapSpotifyLogin];
        return;
    }
    
    // if self is a Soundroom account view, only action is logout
    if (self.isUserAccountView) {
        [self.delegate didTapUserLogout];
        return;
    }
    
    [self.delegate didTapSpotifyLogout];
}

@end
