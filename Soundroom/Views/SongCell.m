//
//  SongCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SongCell.h"
#import "ParseObjectManager.h"
#import "RoomManager.h"

NSString *const addImageName = @"plus";
NSString *const upvoteFilledImageName = @"arrowtriangle.up.fill";
NSString *const upvoteEmptyImageName = @"arrowtriangle.up";
NSString *const downvoteFilledImageName = @"arrowtriangle.down.fill";
NSString *const downvoteEmptyImageName = @"arrowtriangle.down";
NSString *const scoreEmptyLabel = @"0";

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
    
    const CGFloat imageSize = 50.f;
    const CGFloat addButtonSize = 50.f;
    const CGFloat titleHeight = 19.f;
    const CGFloat subtitleHeight = 16.f;
    const CGFloat voteButtonSize = 25.f;
    const CGFloat scoreLabelWidth = _scoreLabel.frame.size.width;
    const CGFloat scoreLabelHeight = _scoreLabel.frame.size.height;
    
    const CGFloat leftPadding = 20.f;
    const CGFloat rightPadding = viewWidth - leftPadding;
    const CGFloat standardPadding = 8.f;
    
    const CGFloat voteButtonTopPadding = (viewHeight - voteButtonSize) / 2.f;
    
    _imageView.frame = CGRectMake(leftPadding, standardPadding, imageSize, imageSize);
    _addButton.frame = CGRectMake(rightPadding - addButtonSize, standardPadding, addButtonSize, addButtonSize);
    _downvoteButton.frame = CGRectMake(rightPadding - voteButtonSize, voteButtonTopPadding, voteButtonSize, voteButtonSize);
    
    const CGFloat smallPadding = 5.f;
    const CGFloat scoreLabelOriginX = CGRectGetMinX(_downvoteButton.frame) - scoreLabelWidth - smallPadding;
    const CGFloat scoreLabelOriginY = (viewHeight - scoreLabelHeight) / 2.f;
    
    _scoreLabel.frame = CGRectMake(scoreLabelOriginX, scoreLabelOriginY, scoreLabelWidth, scoreLabelHeight);
    
    const CGFloat upvoteButtonOriginX = CGRectGetMinX(_scoreLabel.frame) - voteButtonSize - smallPadding;
    
    _upvoteButton.frame = CGRectMake(upvoteButtonOriginX, voteButtonTopPadding, voteButtonSize, voteButtonSize);
    
    const CGFloat labelsPadding = 3.f;
    const CGFloat labelsOriginX = CGRectGetMaxX(_imageView.frame) + standardPadding;
    const CGFloat labelsWidth = CGRectGetMinX(_addButton.frame) - standardPadding - labelsOriginX;
    const CGFloat titleOriginY = (viewHeight - titleHeight - subtitleHeight - labelsPadding) / 2.f;
    
    _titleLabel.frame = CGRectMake(labelsOriginX, titleOriginY, labelsWidth, titleHeight);
    
    const CGFloat subtitleOriginY = CGRectGetMinY(_titleLabel.frame) + labelsPadding;
    
    _subtitleLabel.frame = CGRectMake(labelsOriginX, subtitleOriginY, labelsWidth, subtitleHeight);
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
        _titleLabel.numberOfLines = 1;
        [self.contentView addSubview:_titleLabel];
        
        _subtitleLabel = [UILabel new];
        _subtitleLabel.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightMedium];
        _subtitleLabel.textColor = [UIColor systemGray2Color];
        _subtitleLabel.numberOfLines = 1;
        [self.contentView addSubview:_subtitleLabel];
        
        _addButton = [UIButton new];
        _addButton.userInteractionEnabled = YES;
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
        _scoreLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightRegular];
        _scoreLabel.numberOfLines = 1;
        [self.contentView addSubview:_scoreLabel];
    }
    
    return self;
}

# pragma mark - Buttons

- (void)didTapAdd {
    
    if (_cellType == TrackCell) {
        [ParseObjectManager createRequestInCurrentRoomWithSpotifyId:_objectId];
        return;
    }
    
    [ParseObjectManager createInvitationToCurrentRoomForUserWithId:_objectId];
    
}

- (void)didTapVote:(UIButton *)sender {
    
    if (_voteState == sender.tag) {
        _voteState = NotVoted;
    } else {
        _voteState = sender.tag;
    }
    
    [[RoomManager shared] updateCurrentUserVoteForRequestWithId:_objectId voteState:_voteState];

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
    _cellType = cellType;
    BOOL isQueueCell = cellType == QueueCell;
    _addButton.hidden = isQueueCell;
    _upvoteButton.hidden = !isQueueCell;
    _downvoteButton.hidden = !isQueueCell;
    _scoreLabel.hidden = !isQueueCell;
}

@end
