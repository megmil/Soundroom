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
    
    [_appLabel sizeToFit];
    
    const CGFloat viewWidth = self.frame.size.width;
    const CGFloat viewHeight = self.frame.size.height;
    const CGFloat padding = 8.f;
    
    const CGFloat appImageViewSize = 50.f;
    const CGFloat actionButtonSize = 25.f;
    const CGFloat statusImageViewSize = 20.f;
    
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
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (isLoggedIn) {
            self->_statusImageView.image = [UIImage systemImageNamed:@"checkmark.circle"];
            [self->_actionButton setImage:[UIImage systemImageNamed:@"rectangle.portrait.and.arrow.right"] forState:UIControlStateNormal];
            return;
        }
        self->_statusImageView.image = [UIImage systemImageNamed:@"exclamationmark.triangle"];
        [self->_actionButton setImage:[UIImage systemImageNamed:@"person.fill"] forState:UIControlStateNormal];
    });
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
