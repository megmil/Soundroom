//
//  SongCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SearchCell.h"
#import "QueueSong.h"
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
        [_addButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        [_addButton addTarget:self action:@selector(addItem) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_addButton];
        
        _upvoteButton = [UIButton new];
        [_upvoteButton setImage:[UIImage systemImageNamed:@"arrowtriangle.up"] forState:UIControlStateNormal];
        [_upvoteButton addTarget:self action:@selector(upvoteSong) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_upvoteButton];
        
        _downvoteButton = [UIButton new];
        [_downvoteButton setImage:[UIImage systemImageNamed:@"arrowtriangle.down"] forState:UIControlStateNormal];
        [_downvoteButton addTarget:self action:@selector(downvoteSong) forControlEvents:UIControlEventTouchUpInside];
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

- (void)addItem {
    if (_isAddSongCell) {
        [self addSong];
    } else if (_isUserCell) {
        [self addUser];
    }
}

- (void)addUser {
    [[ParseRoomManager shared] inviteUserWithId:_objectId completion:nil];
}

- (void)addSong {
    [[ParseRoomManager shared] requestSongWithSpotifyId:_objectId completion:nil];
}

- (void)downvoteSong {
    // TODO: downvote song
}

- (void)upvoteSong {
    // TODO: upvote song
}

- (void)setIsAddSongCell:(BOOL)isAddSongCell {
    _isAddSongCell = isAddSongCell;
    _addButton.hidden = !isAddSongCell;
    _upvoteButton.hidden = isAddSongCell;
    _downvoteButton.hidden = isAddSongCell;
    _scoreLabel.hidden = isAddSongCell;
}

- (void)setIsUserCell:(BOOL)isUserCell {
    _isUserCell = isUserCell;
    _addButton.hidden = !isUserCell;
    _upvoteButton.hidden = isUserCell;
    _downvoteButton.hidden = isUserCell;
    _scoreLabel.hidden = isUserCell;
}

- (void)setIsQueueSongCell:(BOOL)isQueueSongCell {
    _isQueueSongCell = isQueueSongCell;
    _addButton.hidden = isQueueSongCell;
    _upvoteButton.hidden = !isQueueSongCell;
    _downvoteButton.hidden = !isQueueSongCell;
    _scoreLabel.hidden = !isQueueSongCell;
}

@end
