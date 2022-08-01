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
    ShimmerLayer *_shimmerLayer;
    
    UIButton *_playButton;
    UIButton *_pauseButton;
    
    UILabel *_nextUpLabel;
    
    UITableView *_tableView;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    const CGFloat viewWidth = CGRectGetWidth(self.frame);
    const CGFloat viewHeight = CGRectGetHeight(self.frame) - self.layoutMargins.bottom;
    
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
    
    const CGFloat playbackButtonsSize = 20.f;
    const CGFloat playbackButtonsOriginY = CGRectGetMinY(_songImageView.frame) + ((imageSize - playbackButtonsSize) / 2.f);
    _playButton.frame = CGRectMake(rightSideEdge - playbackButtonsSize, playbackButtonsOriginY, playbackButtonsSize, playbackButtonsSize);
    
    const CGFloat pauseButtonOriginX = CGRectGetMinX(_playButton.frame) - playbackButtonsSize - standardPadding;
    _pauseButton.frame = CGRectMake(pauseButtonOriginX, playbackButtonsOriginY, playbackButtonsSize, playbackButtonsSize);
    
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
        [self configurePauseButton];
        [self configureNextUpLabel];
        [self configureTableView];
        [self configureShimmerLayer];
        
    }
    
    return self;
    
}

- (void)configureRoomLabel {
    _roomNameLabel = [UILabel new];
    _roomNameLabel.font = [UIFont systemFontOfSize:26.f weight:UIFontWeightSemibold]; // TODO: define font sizes
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

- (void)configurePauseButton {
    _pauseButton = [UIButton new];
    _pauseButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _pauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    _pauseButton.hidden = YES;
    [_pauseButton setImage:[UIImage systemImageNamed:pauseImageName] forState:UIControlStateNormal];
    [_pauseButton addTarget:self action:@selector(pauseButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_pauseButton];
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
    if (_playState == Paused) {
        [self.delegate didTapPlay];
        return;
    }
    [self.delegate didTapSkip];
}

- (void)pauseButtonTapped {
    [self.delegate didTapPause];
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
    BOOL didLoadMaskViews = self.currentSongTitle.length != 0 && self.currentSongArtist.length != 0 && self.currentSongAlbumImage;
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

- (void)setCurrentSongAlbumImage:(UIImage *)currentSongAlbumImage {
    _songImageView.image = currentSongAlbumImage;
}

- (void)setPlayState:(PlayState)playState {
    
    _playState = playState;
    
    _pauseButton.hidden = !(playState == Playing);
    _playButton.enabled = !(playState == Disabled);
    
    UIImage *playButtonImage = (playState == Playing) ? [UIImage systemImageNamed:skipImageName] : [UIImage systemImageNamed:playImageName];
    [_playButton setImage:playButtonImage forState:UIControlStateNormal];
    
    [self setNeedsLayout];
    
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
