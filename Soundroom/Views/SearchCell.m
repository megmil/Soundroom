//
//  SongCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SearchCell.h"
#import "QueueSong.h"
#import "ParseUserManager.h"
#import "ParseRoomManager.h"

@implementation SearchCell {
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
    
    CGFloat imageToLabels = _imageView.frame.origin.x + _imageView.frame.size.width + 8.f;
    CGFloat labelsToButton = _addButton.frame.origin.x + 8.f;
    
    _titleLabel.frame = CGRectMake(imageToLabels, _imageView.frame.origin.y + 6.f, labelsToButton - imageToLabels, 19.f);
    _subtitleLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 3.f, _titleLabel.frame.size.width, 16.f);
    
    [_scoreLabel sizeToFit];
    _downvoteButton.frame = CGRectMake(self.contentView.frame.size.width - 25.f - 20.f, 20.5f, 25.f, 25.f);
    _scoreLabel.frame = CGRectMake(_downvoteButton.frame.origin.x - _downvoteButton.frame.size.width - 5.f, (self.contentView.frame.size.height - _scoreLabel.frame.size.height) / 2.f, _scoreLabel.frame.size.width, _scoreLabel.frame.size.height);
    _upvoteButton.frame = CGRectMake(_scoreLabel.frame.origin.x - _scoreLabel.frame.size.width - 5.f, 20.5f, 25.f, 25.f);
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
        [_addButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addSong) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_addButton];
        
        _upvoteButton = [UIButton new];
        [_upvoteButton addTarget:self action:@selector(didTapUpvote) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_upvoteButton];
        
        _downvoteButton = [UIButton new];
        [_downvoteButton addTarget:self action:@selector(didTapDownvote) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_downvoteButton];
        
        _scoreLabel = [UILabel new];
        _scoreLabel.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightRegular];
        _scoreLabel.numberOfLines = 1;
        [self.contentView addSubview:_scoreLabel];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setSubtitle:(NSString *)subtitle {
    _subtitleLabel.text = subtitle;
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}

# pragma mark - Add Song/User Cell

- (void)addItem {
    if (_isAddSongCell) {
        [self addSong];
    } else if (_isUserCell) {
        [self addUser];
    }
}

- (void)addSong {
    [[ParseRoomManager shared] requestSongWithSpotifyId:_objectId completion:nil];
}

- (void)addUser {
    [[ParseRoomManager shared] inviteUserWithId:_objectId completion:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self->_addButton setImage:[UIImage systemImageNamed:@"circle.inset.filled"] forState:UIControlStateNormal];
            self->_addButton.userInteractionEnabled = NO;
        }
    }];
}

# pragma mark - Queue Song Cell

- (void)didTapUpvote {
    
    // user upvotedSongIds and downvotedSongIds
    [ParseUserManager upvoteQueueSongWithId:_objectId];
    
    // queue song score
    NSNumber *increment;
    if (_isDownvoted) {
        increment = @(2);
    } else if (_isUpvoted) {
        increment = @(-1);
    } else {
        increment = @(1);
    }
    [QueueSong incrementScoreForQueueSongWithId:_objectId byAmount:increment completion:nil];
    
    // buttons
    if (_isDownvoted) {
        self.isUpvoted = YES;
        return;
    }
    self.isUnvoted = YES;
    
}

- (void)didTapDownvote {
    
    // user upvotedSongIds and downvotedSongIds
    [ParseUserManager downvoteQueueSongWithId:_objectId];
    
    // queue song score
    NSNumber *increment;
    if (_isDownvoted) {
        increment = @(1);
    } else if (_isUpvoted) {
        increment = @(-2);
    } else {
        increment = @(-1);
    }
    [QueueSong incrementScoreForQueueSongWithId:_objectId byAmount:increment completion:nil];
    
    // buttons
    if (_isUpvoted) {
        self.isDownvoted = YES;
        return;
    }
    self.isUnvoted = YES;
    
}

- (void)setIsUpvoted:(BOOL)isUpvoted {
    _isUpvoted = isUpvoted;
    if (isUpvoted) {
        self.isDownvoted = NO;
        self.isUnvoted = NO;
        [_upvoteButton setImage:[UIImage systemImageNamed:@"arrowtriangle.up.fill"] forState:UIControlStateNormal];
    } else {
        [_upvoteButton setImage:[UIImage systemImageNamed:@"arrowtriangle.up"] forState:UIControlStateNormal];
    }
}

- (void)setIsDownvoted:(BOOL)isDownvoted {
    _isDownvoted = isDownvoted;
    if (isDownvoted) {
        self.isUpvoted = NO;
        self.isUnvoted = NO;
        [_downvoteButton setImage:[UIImage systemImageNamed:@"arrowtriangle.down.fill"] forState:UIControlStateNormal];
    } else {
        [_downvoteButton setImage:[UIImage systemImageNamed:@"arrowtriangle.down"] forState:UIControlStateNormal];
    }
}

- (void)setIsUnvoted:(BOOL)isUnvoted {
    _isUnvoted = isUnvoted;
    if (isUnvoted) {
        _isUpvoted = NO;
        _isDownvoted = NO;
        [_upvoteButton setImage:[UIImage systemImageNamed:@"arrowtriangle.up"] forState:UIControlStateNormal];
        [_downvoteButton setImage:[UIImage systemImageNamed:@"arrowtriangle.down"] forState:UIControlStateNormal];
    }
}

# pragma mark - Set Cell Type

- (void)setIsAddSongCell:(BOOL)isAddSongCell {
    _isAddSongCell = isAddSongCell;
    _addButton.hidden = !isAddSongCell;
    _upvoteButton.hidden = isAddSongCell;
    _downvoteButton.hidden = isAddSongCell;
    _scoreLabel.hidden = isAddSongCell;
    [_addButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal]; // TODO: check if already added
}

- (void)setIsUserCell:(BOOL)isUserCell {
    _isUserCell = isUserCell;
    _addButton.hidden = !isUserCell;
    _upvoteButton.hidden = isUserCell;
    _downvoteButton.hidden = isUserCell;
    _scoreLabel.hidden = isUserCell;
    [_addButton setImage:[UIImage systemImageNamed:@"circle"] forState:UIControlStateNormal]; // TODO: check if already added
}

- (void)setIsQueueSongCell:(BOOL)isQueueSongCell {
    _isQueueSongCell = isQueueSongCell;
    _addButton.hidden = isQueueSongCell;
    _upvoteButton.hidden = !isQueueSongCell;
    _downvoteButton.hidden = !isQueueSongCell;
    _scoreLabel.hidden = !isQueueSongCell;
}

@end
