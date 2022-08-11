//
//  SongCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SongCell.h"
#import "ImageConstants.h"
#import "ShimmerLayer.h"
#import "UIImageView+AFNetworking.h"
#import "UIView+TapAnimation.h"

static NSString *const scoreEmptyLabel = @"0";

static const CGFloat largeViewSize = 50.f;
static const CGFloat standardPadding = 8.f;
static const CGFloat titleFontSize = 16.f;
static const CGFloat subtitleFontSize = 13.f;
static const CGFloat scoreFontSize = 14.f;
static const CGFloat imageCornerRadius = 0.06f * largeViewSize;
static const CGFloat cellHeight = largeViewSize + (2 * standardPadding);

@implementation SongCell {
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_imageView;
    
    UIButton *_addButton;
    UIButton *_upvoteButton;
    UIButton *_downvoteButton;
    UILabel *_scoreLabel;
    
    ShimmerLayer *_shimmerLayer;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [_scoreLabel sizeToFit];
    
    const CGFloat viewWidth = self.contentView.frame.size.width;
    const CGFloat viewHeight = cellHeight;
    
    const CGFloat leftPadding = 20.f;
    const CGFloat rightPadding = viewWidth - leftPadding;
    const CGFloat smallPadding = 5.f;
    const CGFloat labelsPadding = 3.f;
    
    const CGFloat largeViewOriginY = (viewHeight - largeViewSize) / 2.f;
    
    const CGFloat voteButtonSize = 25.f;
    const CGFloat voteButtonOriginY = (viewHeight - voteButtonSize) / 2.f;
    
    const CGFloat titleLabelHeight = 19.f;
    const CGFloat subtitleLabelHeight = 16.f;
    
    _imageView.frame = CGRectMake(leftPadding, largeViewOriginY, largeViewSize, largeViewSize);
    _addButton.frame = CGRectMake(rightPadding - largeViewSize, largeViewOriginY, largeViewSize, largeViewSize);
    _downvoteButton.frame = CGRectMake(rightPadding - voteButtonSize, voteButtonOriginY, voteButtonSize, voteButtonSize);
    
    const CGFloat scoreLabelWidth = _scoreLabel.frame.size.width;
    const CGFloat scoreLabelHeight = _scoreLabel.frame.size.height;
    const CGFloat scoreLabelOriginX = CGRectGetMinX(_downvoteButton.frame) - scoreLabelWidth - smallPadding;
    const CGFloat scoreLabelOriginY = (viewHeight - scoreLabelHeight) / 2.f;
    _scoreLabel.frame = CGRectMake(scoreLabelOriginX, scoreLabelOriginY, scoreLabelWidth, scoreLabelHeight);
    
    const CGFloat upvoteButtonOriginX = CGRectGetMinX(_scoreLabel.frame) - voteButtonSize - smallPadding;
    _upvoteButton.frame = CGRectMake(upvoteButtonOriginX, voteButtonOriginY, voteButtonSize, voteButtonSize);
    
    const CGFloat labelsOriginX = CGRectGetMaxX(_imageView.frame) + standardPadding;
    const CGFloat rightViewsMinX = (_cellType == QueueCell) ? CGRectGetMinX(_upvoteButton.frame) : CGRectGetMinX(_addButton.frame);
    const CGFloat labelsWidth = rightViewsMinX - smallPadding - labelsOriginX;
    const CGFloat titleOriginY = (viewHeight - titleLabelHeight - subtitleLabelHeight - labelsPadding) / 2.f;
    _titleLabel.frame = CGRectMake(labelsOriginX, titleOriginY, labelsWidth, titleLabelHeight);
    
    const CGFloat subtitleOriginY = CGRectGetMaxY(_titleLabel.frame) + labelsPadding;
    _subtitleLabel.frame = CGRectMake(labelsOriginX, subtitleOriginY, labelsWidth, subtitleLabelHeight);
    
    [self layoutShimmerLayer];
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(size.width, cellHeight);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self configureImageView];
        [self configureTitleLabel];
        [self configureSubtitleLabel];
        [self configureAddButton];
        [self configureUpvoteButton];
        [self configureDownvoteButton];
        [self configureScoreLabel];
        [self configureShimmerLayer];
        
    }
    
    return self;
}

- (void)configureImageView {
    _imageView = [UIImageView new];
    _imageView.layer.cornerRadius = imageCornerRadius;
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
}

- (void)configureTitleLabel {
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:titleFontSize weight:UIFontWeightMedium];
    [self.contentView addSubview:_titleLabel];
}

- (void)configureSubtitleLabel {
    _subtitleLabel = [UILabel new];
    _subtitleLabel.font = [UIFont systemFontOfSize:subtitleFontSize weight:UIFontWeightMedium];
    _subtitleLabel.textColor = [UIColor systemGray2Color];
    [self.contentView addSubview:_subtitleLabel];
}

- (void)configureAddButton {
    _addButton = [UIButton new];
    [_addButton setImage:[UIImage systemImageNamed:plusImageName] forState:UIControlStateNormal];
    [_addButton addTarget:self action:@selector(didTapAdd) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_addButton];
}

- (void)configureUpvoteButton {
    _upvoteButton = [UIButton new];
    _upvoteButton.tag = Upvoted;
    [_upvoteButton addTarget:self action:@selector(didTapVote:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_upvoteButton];
}

- (void)configureDownvoteButton {
    _downvoteButton = [UIButton new];
    _downvoteButton.tag = Downvoted;
    [_downvoteButton addTarget:self action:@selector(didTapVote:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_downvoteButton];
}

- (void)configureScoreLabel {
    _scoreLabel = [UILabel new];
    _scoreLabel.font = [UIFont systemFontOfSize:scoreFontSize weight:UIFontWeightRegular];
    [self.contentView addSubview:_scoreLabel];
}

- (void)configureShimmerLayer {
    _shimmerLayer = [ShimmerLayer new];
    [self.layer addSublayer:_shimmerLayer];
}

# pragma mark - Buttons

- (void)didTapAdd {
    [_addButton animateWithScaleSize:Large completion:^{
        [self->_addDelegate didAddObjectWithId:self->_objectId deezerId:self->_deezerId];
    }];
}

- (void)didTapVote:(UIButton *)sender {

    if (_voteState == sender.tag) {
        _voteState = NotVoted;
    } else {
        _voteState = sender.tag;
    }
    
    [self.queueDelegate didUpdateVoteStateForRequestWithId:_objectId voteState:_voteState];
    [self animateVoteButton:sender voteState:_voteState];
    
}

- (void)animateVoteButton:(UIButton *)sender voteState:(VoteState)voteState {

    CGFloat direction = ((voteState == NotVoted) ? 1.f : -1.f) * sender.tag;
    CGFloat multiplier = 5.f;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.translation.y";
    animation.fromValue = @(1);
    animation.toValue = @(direction * multiplier);
    animation.duration = 0.1;
    animation.autoreverses = YES;
    [sender.layer addAnimation:animation forKey:@"basic"];
    
}

# pragma mark - Shimmer

- (void)layoutShimmerLayer {
    
    if (!_imageView || !_titleLabel || !_subtitleLabel) {
        return;
    }
    
    const CGFloat width = CGRectGetMaxX(_titleLabel.frame);
    const CGRect frame = CGRectMake(0.f, 0.f, width, cellHeight);
    
    [_shimmerLayer maskWithViews:@[_imageView, _titleLabel, _subtitleLabel] frame:frame];
    
    BOOL didLoadMaskViews = self.title.length != 0 && self.subtitle.length != 0;
    _imageView.image = didLoadMaskViews ? _imageView.image : nil;
    _shimmerLayer.isAnimating = !didLoadMaskViews;
    
}

# pragma mark - Properties

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitleLabel.text = subtitle;
}

- (void)setImageURL:(NSURL *)imageURL {
    [_imageView setImageWithURL:imageURL];
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}

- (NSString *)title {
    return _titleLabel.text;
}

- (NSString *)subtitle {
    return _subtitleLabel.text;
}

- (void)setScore:(NSNumber *)score {
    
    if (!score) {
        _scoreLabel.text = scoreEmptyLabel;
        return;
    }
    
    _scoreLabel.text = [score stringValue];
    
}

- (void)setVoteState:(VoteState)voteState {
    
    _voteState = voteState;
    
    if (voteState == Upvoted) {
        [_upvoteButton setImage:[UIImage systemImageNamed:upvoteFilledImageName] forState:UIControlStateNormal];
        [_downvoteButton setImage:[UIImage systemImageNamed:downvoteEmptyImageName] forState:UIControlStateNormal];
    } else if (voteState == Downvoted) {
        [_upvoteButton setImage:[UIImage systemImageNamed:upvoteEmptyImageName] forState:UIControlStateNormal];
        [_downvoteButton setImage:[UIImage systemImageNamed:downvoteFilledImageName] forState:UIControlStateNormal];
    } else {
        [_upvoteButton setImage:[UIImage systemImageNamed:upvoteEmptyImageName] forState:UIControlStateNormal];
        [_downvoteButton setImage:[UIImage systemImageNamed:downvoteEmptyImageName] forState:UIControlStateNormal];
    }
    
}

- (void)setCellType:(SongCellType)cellType {
    BOOL isQueueCell = cellType == QueueCell;
    _addButton.hidden = isQueueCell;
    _upvoteButton.hidden = !isQueueCell;
    _downvoteButton.hidden = !isQueueCell;
    _scoreLabel.hidden = !isQueueCell;
    _cellType = cellType;
}

@end
