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
    
    _imageView.frame = CGRectMake(20.f, 8.f, 50.f, 50.f);
    _addButton.frame = CGRectMake(self.contentView.frame.size.width - 50.f - 20.f, 8.f, 50.f, 50.f);
    
    const CGFloat imageToLabels = _imageView.frame.origin.x + _imageView.frame.size.width + 8.f;
    const CGFloat labelsToButton = _addButton.frame.origin.x + 8.f;
    
    _titleLabel.frame = CGRectMake(imageToLabels, _imageView.frame.origin.y + 6.f, labelsToButton - imageToLabels, 19.f);
    _subtitleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 3.f, _titleLabel.frame.size.width, 16.f);
    
    [_scoreLabel sizeToFit];
    _downvoteButton.frame = CGRectMake(self.contentView.frame.size.width - 25.f - 20.f, 20.5f, 25.f, 25.f);
    _scoreLabel.frame = CGRectMake(_downvoteButton.frame.origin.x - _scoreLabel.frame.size.width - 5.f, (self.contentView.frame.size.height - _scoreLabel.frame.size.height) / 2.f, _scoreLabel.frame.size.width, _scoreLabel.frame.size.height);
    _upvoteButton.frame = CGRectMake(_scoreLabel.frame.origin.x - 25.f - 5.f, 20.5f, 25.f, 25.f);
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
