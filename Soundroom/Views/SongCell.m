//
//  SongCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SongCell.h"

static NSString *const addImageName = @"plus";
static NSString *const upvoteFilledImageName = @"arrowtriangle.up.fill";
static NSString *const upvoteEmptyImageName = @"arrowtriangle.up";
static NSString *const downvoteFilledImageName = @"arrowtriangle.down.fill";
static NSString *const downvoteEmptyImageName = @"arrowtriangle.down";
static NSString *const scoreEmptyLabel = @"0";

static CGFloat const largeViewSize = 50.f;
static CGFloat const titleFontSize = 16.f;
static CGFloat const subtitleFontSize = 13.f;
static CGFloat const scoreFontSize = 14.f;
static CGFloat const imageCornerRadius = 0.06f * largeViewSize;

@implementation SongCell {
    
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UIImageView *_imageView;
    
    UIButton *_addButton;
    UIButton *_upvoteButton;
    UIButton *_downvoteButton;
    UILabel *_scoreLabel;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [_scoreLabel sizeToFit];
    
    const CGFloat viewWidth = self.contentView.frame.size.width;
    const CGFloat viewHeight = self.contentView.frame.size.height;
    
    const CGFloat titleHeight = 19.f;
    const CGFloat subtitleHeight = 16.f;
    const CGFloat voteButtonSize = 25.f;
    const CGFloat scoreLabelWidth = _scoreLabel.frame.size.width;
    const CGFloat scoreLabelHeight = _scoreLabel.frame.size.height;
    
    const CGFloat leftPadding = 20.f;
    const CGFloat rightPadding = viewWidth - leftPadding;
    const CGFloat standardPadding = 8.f;
    const CGFloat smallPadding = 5.f;
    
    const CGFloat voteButtonTopPadding = (viewHeight - voteButtonSize) / 2.f;
    
    _imageView.frame = CGRectMake(leftPadding, standardPadding, largeViewSize, largeViewSize);
    _addButton.frame = CGRectMake(rightPadding - largeViewSize, standardPadding, largeViewSize, largeViewSize);
    _downvoteButton.frame = CGRectMake(rightPadding - voteButtonSize, voteButtonTopPadding, voteButtonSize, voteButtonSize);
    
    const CGFloat scoreLabelOriginX = CGRectGetMinX(_downvoteButton.frame) - scoreLabelWidth - smallPadding;
    const CGFloat scoreLabelOriginY = (viewHeight - scoreLabelHeight) / 2.f;
    
    _scoreLabel.frame = CGRectMake(scoreLabelOriginX, scoreLabelOriginY, scoreLabelWidth, scoreLabelHeight);
    
    const CGFloat upvoteButtonOriginX = CGRectGetMinX(_scoreLabel.frame) - voteButtonSize - smallPadding;
    
    _upvoteButton.frame = CGRectMake(upvoteButtonOriginX, voteButtonTopPadding, voteButtonSize, voteButtonSize);
    
    const CGFloat labelsPadding = 3.f;
    const CGFloat labelsOriginX = CGRectGetMaxX(_imageView.frame) + standardPadding;
    const CGFloat rightViewsMinX = (_cellType == QueueCell) ? CGRectGetMinX(_upvoteButton.frame) : CGRectGetMinX(_addButton.frame);
    const CGFloat labelsWidth = rightViewsMinX - smallPadding - labelsOriginX;
    const CGFloat titleOriginY = (viewHeight - titleHeight - subtitleHeight - labelsPadding) / 2.f;
    
    _titleLabel.frame = CGRectMake(labelsOriginX, titleOriginY, labelsWidth, titleHeight);
    
    const CGFloat subtitleOriginY = CGRectGetMaxY(_titleLabel.frame) + labelsPadding;
    
    _subtitleLabel.frame = CGRectMake(labelsOriginX, subtitleOriginY, labelsWidth, subtitleHeight);
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _imageView = [UIImageView new];
        _imageView.layer.cornerRadius = imageCornerRadius;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:titleFontSize weight:UIFontWeightMedium];
        [self.contentView addSubview:_titleLabel];
        
        _subtitleLabel = [UILabel new];
        _subtitleLabel.font = [UIFont systemFontOfSize:subtitleFontSize weight:UIFontWeightMedium];
        _subtitleLabel.textColor = [UIColor systemGray2Color];
        [self.contentView addSubview:_subtitleLabel];
        
        _addButton = [UIButton new];
        [_addButton setImage:[UIImage systemImageNamed:addImageName] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(didTapAdd) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_addButton];
        
        _upvoteButton = [UIButton new];
        _upvoteButton.tag = Upvoted;
        [_upvoteButton addTarget:self action:@selector(didTapVote:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_upvoteButton];
        
        _downvoteButton = [UIButton new];
        _downvoteButton.tag = Downvoted;
        [_downvoteButton addTarget:self action:@selector(didTapVote:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_downvoteButton];
        
        _scoreLabel = [UILabel new];
        _scoreLabel.font = [UIFont systemFontOfSize:scoreFontSize weight:UIFontWeightRegular];
        [self.contentView addSubview:_scoreLabel];
        
    }
    
    return self;
}

# pragma mark - Buttons

- (void)didTapAdd {
    [self.addDelegate didAddObjectWithId:_objectId];
    _addButton.transform = CGAffineTransformMakeScale(1.4f, 1.4f);
    [UIView animateWithDuration:0.6
                          delay:0.1
         usingSpringWithDamping:0.8f
          initialSpringVelocity:0.5f
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{ self->_addButton.transform = CGAffineTransformIdentity; }
                     completion:nil];
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
    CGFloat multiplier = 10.f;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.translation.y";
    animation.fromValue = @(1);
    animation.toValue = @(multiplier * direction);
    animation.duration = 0.2;
    animation.autoreverses = YES;
    animation.fillMode = kCAFillModeForwards;
    [sender.layer addAnimation:animation forKey:@"basic"];
    
}

# pragma mark - Setters

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitleLabel.text = subtitle;
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
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
