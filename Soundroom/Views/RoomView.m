//
//  RoomView.m
//  Soundroom
//
//  Created by Megan Miller on 7/28/22.
//

#import "RoomView.h"
#import "ImageConstants.h"
#import "ShimmerLayer.h"

static const CGFloat imageSize = 70.f;
static const CGFloat cornerRadiusRatio = 0.06f;

@implementation RoomView {
    
    UILabel *_roomNameLabel;
    UIButton *_leaveButton;
    
    UILabel *_songTitleLabel;
    UILabel *_songArtistLabel;
    UIImageView *_songImageView;
    UIButton *_playButton;
    ShimmerLayer *_shimmerLayer;
    
    UILabel *_nextUpLabel;
    
    UITableView *_tableView;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    const CGFloat viewWidth = CGRectGetWidth(self.frame);
    const CGFloat viewHeight = CGRectGetHeight(self.frame);
    
    const CGFloat topEdge = self.safeAreaInsets.top;
    const CGFloat leftSideEdge = 20.f;
    const CGFloat standardPadding = 8.f;
    const CGFloat smallPadding = 2.f;
    const CGFloat rightSideEdge = viewWidth - leftSideEdge;
    
    [_leaveButton sizeToFit];
    const CGFloat leaveButtonWidth = CGRectGetWidth(_leaveButton.frame);
    const CGFloat leaveButtonHeight = CGRectGetHeight(_leaveButton.frame);
    _leaveButton.frame = CGRectMake(rightSideEdge - leaveButtonWidth, topEdge, leaveButtonWidth, leaveButtonHeight);
    
    [_roomNameLabel sizeToFit];
    const CGFloat roomLabelHeight = CGRectGetHeight(_roomNameLabel.frame);
    const CGFloat roomLabelWidth = CGRectGetMinX(_leaveButton.frame) - standardPadding - leftSideEdge;
    _roomNameLabel.frame = CGRectMake(leftSideEdge, topEdge, roomLabelWidth, roomLabelHeight);
    
    const CGFloat songImageViewOriginY = CGRectGetMaxY(_roomNameLabel.frame) + leftSideEdge;
    _songImageView.frame = CGRectMake(leftSideEdge, songImageViewOriginY, imageSize, imageSize);
    
    const CGFloat playButtonSize = 20.f;
    const CGFloat playButtonOriginY = CGRectGetMinY(_songImageView.frame) + ((imageSize - playButtonSize) / 2.f);
    _playButton.frame = CGRectMake(rightSideEdge - playButtonSize, playButtonOriginY, playButtonSize, playButtonSize);
    
    const CGFloat songTitleLabelHeight = 22.f;
    const CGFloat songArtistLabelHeight = 18.f;
    const CGFloat songLabelsHeight = songTitleLabelHeight + songArtistLabelHeight + smallPadding;
    const CGFloat songTitleLabelOriginY = CGRectGetMinY(_songImageView.frame) + ((imageSize - songLabelsHeight) / 2.f);
    const CGFloat songArtistLabelOriginY = songTitleLabelOriginY + songTitleLabelHeight + smallPadding;
    const CGFloat songLabelsOriginX = CGRectGetMaxX(_songImageView.frame) + standardPadding;
    const CGFloat songLabelsWidth = CGRectGetMinX(_playButton.frame) - standardPadding - songLabelsOriginX;
    _songTitleLabel.frame = CGRectMake(songLabelsOriginX, songTitleLabelOriginY, songLabelsWidth, songTitleLabelHeight);
    _songArtistLabel.frame = CGRectMake(songLabelsOriginX, songArtistLabelOriginY, songLabelsWidth, songArtistLabelHeight);
    
    [_nextUpLabel sizeToFit];
    const CGFloat nextUpLabelOriginY = CGRectGetMaxY(_songImageView.frame) + leftSideEdge;
    _nextUpLabel.frame = CGRectMake(leftSideEdge, nextUpLabelOriginY, CGRectGetWidth(_nextUpLabel.frame), CGRectGetHeight(_nextUpLabel.frame));
    
    const CGFloat tableViewOriginY = CGRectGetMaxY(_nextUpLabel.frame) + standardPadding;
    const CGFloat tableViewHeight = viewHeight - tableViewOriginY;
    _tableView.frame = CGRectMake(0.f, tableViewOriginY, viewWidth, tableViewHeight);
    
    [self layoutShimmerLayer];
    
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    if (self) {
        
        _roomNameLabel = [UILabel new];
        _roomNameLabel.font = [UIFont systemFontOfSize:26.f weight:UIFontWeightSemibold]; // TODO: define font sizes
        [self addSubview:_roomNameLabel];
        
        _leaveButton = [UIButton new];
        _leaveButton.titleLabel.text = @"Leave";
        _leaveButton.tintColor = [UIColor systemRedColor];
        [self addSubview:_leaveButton];
        
        _songTitleLabel = [UILabel new];
        _songTitleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightMedium];
        [self addSubview:_songTitleLabel];
        
        _songArtistLabel = [UILabel new];
        _songArtistLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
        _songArtistLabel.textColor = [UIColor systemGray2Color];
        [self addSubview:_songArtistLabel];
        
        _songImageView = [UIImageView new];
        _songImageView.contentMode = UIViewContentModeScaleAspectFill;
        _songImageView.layer.cornerRadius = imageSize * cornerRadiusRatio;
        _songImageView.clipsToBounds = YES;
        [self addSubview:_songImageView];
        
        _playButton = [UIButton new];
        _playButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        _playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        [_playButton setImage:[UIImage systemImageNamed:playImageName] forState:UIControlStateNormal];
        [_playButton addTarget:self action:@selector(playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_playButton];
        
        _nextUpLabel = [UILabel new];
        _nextUpLabel.text = @"Next up";
        _nextUpLabel.font = [UIFont systemFontOfSize:20.f weight:UIFontWeightMedium];
        [self addSubview:_nextUpLabel];
        
        _tableView = [UITableView new];
        _tableView.backgroundColor = [UIColor redColor];
        [self addSubview:_tableView];
        
        _shimmerLayer = [ShimmerLayer new];
        [self.layer addSublayer:_shimmerLayer];
        
    }
    
    return self;
    
}

# pragma mark - Playback

- (void)playButtonTapped {
    
    // update property
    _isPaused = !_isPaused;
    
    // update UI
    _playButton.imageView.image = _isPaused ? [UIImage imageNamed:pauseImageName] : [UIImage imageNamed:playImageName];
    
    // update playback in delegate
    [self.delegate didTapPlay];
    
}

# pragma mark - Shimmer

- (void)layoutShimmerLayer {
    
    if (!_songImageView || !_songTitleLabel || !_songArtistLabel) {
        return;
    }
    
    const CGRect frame = self.layer.bounds;
    [_shimmerLayer maskWithViews:@[_songImageView, _songTitleLabel, _songArtistLabel] frame:frame];
    [self animateShimmer];
    
}

- (void)animateShimmer {
    if (self.currentSongTitle.length != 0 && self.currentSongArtist.length != 0 && self.currentSongAlbumImage) {
        [_shimmerLayer stopAnimating];
        return;
    }
    [_shimmerLayer startAnimating];
}

# pragma mark - Setters

- (void)setRoomName:(NSString *)roomName {
    _roomNameLabel.text = roomName;
}

- (void)setIsHostView:(BOOL)isHostView {
    _playButton.enabled = isHostView;
}

- (void)setCurrentSongTitle:(NSString *)currentSongTitle {
    _songTitleLabel.text = currentSongTitle;
}

- (void)setCurrentSongArtist:(NSString *)currentSongArtist {
    _songArtistLabel.text = currentSongArtist;
}

- (void)setCurrentSongAlbumImage:(UIImage *)currentSongAlbumImage {
    _songImageView.image = currentSongAlbumImage;
}

# pragma mark - Getters

- (NSString *)currentSongTitle {
    return _songTitleLabel.text;
}

- (NSString *)currentSongArtist {
    return _songArtistLabel.text;
}

- (UIImage *)currentSongAlbumImage {
    return _songImageView.image;
}

- (UITableView *)tableView {
    return _tableView;
}

@end
