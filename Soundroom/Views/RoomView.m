//
//  RoomView.m
//  Soundroom
//
//  Created by Megan Miller on 7/28/22.
//

#import "RoomView.h"
#import "ImageConstants.h"
#import "ShimmerLayer.h"
#import "UIImageView+AFNetworking.h"

static const CGFloat imageSize = 70.f;
static const CGFloat cornerRadiusRatio = 0.06f;
static const CGFloat playbackButtonsSize = 20.f;
static const CGFloat leftSideEdge = 20.f;
static const CGFloat standardPadding = 8.f;

@implementation RoomView {
    
    UILabel *_roomNameLabel;
    UIButton *_leaveButton;
    
    UILabel *_songTitleLabel;
    UILabel *_songArtistLabel;
    UIImageView *_songImageView;
    ShimmerLayer *_shimmerLayer;
    
    UIButton *_playButton;
    UIButton *_skipButton;
    
    UILabel *_nextUpLabel;
    
    UITableView *_tableView;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    const CGFloat viewWidth = CGRectGetWidth(self.frame);
    const CGFloat viewHeight = CGRectGetHeight(self.frame) - self.layoutMargins.bottom;
    
    const CGFloat topEdge = self.safeAreaInsets.top;
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
    
    const CGFloat playbackButtonsOriginY = CGRectGetMinY(_songImageView.frame) + ((imageSize - playbackButtonsSize) / 2.f);
    _skipButton.frame = CGRectMake(rightSideEdge - playbackButtonsSize, playbackButtonsOriginY, playbackButtonsSize, playbackButtonsSize);
    _playButton.frame = _skipButton.frame;
    
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
        
        [self configureRoomLabel];
        [self configureLeaveButton];
        [self configureSongTitleLabel];
        [self configureSongArtistLabel];
        [self configureSongImageView];
        [self configurePlayButton];
        [self configureSkipButton];
        [self configureNextUpLabel];
        [self configureTableView];
        [self configureShimmerLayer];
        
    }
    
    return self;
    
}

- (void)configureRoomLabel {
    _roomNameLabel = [UILabel new];
    _roomNameLabel.font = [UIFont systemFontOfSize:26.f weight:UIFontWeightSemibold];
    [self addSubview:_roomNameLabel];
}

- (void)configureLeaveButton {
    _leaveButton = [UIButton new];
    [_leaveButton setTitle:@"Leave" forState:UIControlStateNormal];
    [_leaveButton setTitleColor:[UIColor systemRedColor] forState:UIControlStateNormal];
    _leaveButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [_leaveButton addTarget:self action:@selector(leaveButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_leaveButton];
}

- (void)configureSongTitleLabel {
    _songTitleLabel = [UILabel new];
    _songTitleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightMedium];
    [self addSubview:_songTitleLabel];
}

- (void)configureSongArtistLabel {
    _songArtistLabel = [UILabel new];
    _songArtistLabel.font = [UIFont systemFontOfSize:15.f weight:UIFontWeightMedium];
    _songArtistLabel.textColor = [UIColor systemGray2Color];
    [self addSubview:_songArtistLabel];
}

- (void)configureSongImageView {
    _songImageView = [UIImageView new];
    _songImageView.contentMode = UIViewContentModeScaleAspectFill;
    _songImageView.layer.cornerRadius = imageSize * cornerRadiusRatio;
    _songImageView.layer.masksToBounds = YES;
    [self addSubview:_songImageView];
}

- (void)configurePlayButton {
    _playButton = [UIButton new];
    _playButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _playButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [_playButton setImage:[UIImage systemImageNamed:playImageName] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_playButton];
}

- (void)configureSkipButton {
    _skipButton = [UIButton new];
    _skipButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _skipButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    self.isSkipButtonHidden = YES;
    [_skipButton setImage:[UIImage systemImageNamed:skipImageName] forState:UIControlStateNormal];
    [_skipButton addTarget:self action:@selector(skipButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_skipButton];
}

- (void)configureNextUpLabel {
    _nextUpLabel = [UILabel new];
    _nextUpLabel.text = @"Next up";
    _nextUpLabel.font = [UIFont systemFontOfSize:20.f weight:UIFontWeightMedium];
    [self addSubview:_nextUpLabel];
}

- (void)configureTableView {
    _tableView = [UITableView new];
    [self addSubview:_tableView];
}

- (void)configureShimmerLayer {
    _shimmerLayer = [ShimmerLayer new];
    [self.layer addSublayer:_shimmerLayer];
}

# pragma mark - RoomViewDelegate

- (void)playButtonTapped {
    _playState == Paused ? [_delegate didTapPlay] : [_delegate didTapPause];
}

- (void)skipButtonTapped {
    [self.delegate didTapSkip];
}

- (void)leaveButtonTapped {
    [self.delegate didTapLeave];
}

# pragma mark - Shimmer

- (void)layoutShimmerLayer {
    
    if (!_songImageView || !_songTitleLabel || !_songArtistLabel) {
        return;
    }
    
    const CGRect frame = self.layer.bounds;
    [_shimmerLayer maskWithViews:@[_songImageView, _songTitleLabel, _songArtistLabel] frame:frame];
    
    [self refreshAnimations];
    
}

- (void)refreshAnimations {
    BOOL didLoadMaskViews = self.currentSongTitle.length != 0 && self.currentSongArtist.length != 0;
    _shimmerLayer.isAnimating = !didLoadMaskViews;
}

# pragma mark - Setters

- (void)setRoomName:(NSString *)roomName {
    _roomNameLabel.text = roomName;
}

- (void)setCurrentSongTitle:(NSString *)currentSongTitle {
    _songTitleLabel.text = currentSongTitle;
}

- (void)setCurrentSongArtist:(NSString *)currentSongArtist {
    _songArtistLabel.text = currentSongArtist;
}

- (void)setCurrentSongAlbumImageURL:(NSURL *)currentSongAlbumImageURL {
    [_songImageView setImageWithURL:currentSongAlbumImageURL];
}

- (void)setPlayState:(PlayState)playState {
    
    if (_playState == playState) {
        return;
    }
    
    _playState = playState;
    
    _playButton.enabled = !(playState == Disabled);
    if (playState == Disabled) {
        self.skipButtonHidden = YES;
    }
    
    UIImage *playButtonImage = (playState == Playing) ? [UIImage systemImageNamed:pauseImageName] : [UIImage systemImageNamed:playImageName];
    [_playButton setImage:playButtonImage forState:UIControlStateNormal];
    
    [self setNeedsLayout];
    
}

- (void)setSkipButtonHidden:(BOOL)isSkipButtonHidden {
    
    if (_isSkipButtonHidden == isSkipButtonHidden) {
        return;
    }
    
    _isSkipButtonHidden = isSkipButtonHidden;
    _skipButton.hidden = isSkipButtonHidden;
    
    if (isSkipButtonHidden) {
        _playButton.frame = _skipButton.frame;
        return;
    }
    
    const CGFloat playButtonTopEdge = CGRectGetMinY(_playButton.frame);
    const CGFloat leftPlayButtonLeftEdge = CGRectGetMinX(_skipButton.frame) - playbackButtonsSize - standardPadding;
    const CGRect leftButtonFrame = CGRectMake(leftPlayButtonLeftEdge, playButtonTopEdge, playbackButtonsSize, playbackButtonsSize);
    
    _playButton.frame = leftButtonFrame;
    
    [self setNeedsLayout];
    
}

# pragma mark - Getters

- (NSString *)currentSongTitle {
    return _songTitleLabel.text;
}

- (NSString *)currentSongArtist {
    return _songArtistLabel.text;
}

- (UITableView *)tableView {
    return _tableView;
}

@end
