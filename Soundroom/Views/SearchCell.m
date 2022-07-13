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
    
    CGFloat imageToLabels = _imageView.frame.origin.x + _imageView.frame.size.width + 8.f; // TODO: rename
    CGFloat labelsToButton = _addButton.frame.origin.x + 8.f; // TODO: rename
    
    _titleLabel.frame = CGRectMake(imageToLabels, _imageView.frame.origin.y + 6.f,
                                   labelsToButton - imageToLabels, 19.f);
    _subtitleLabel.frame = CGRectMake(_titleLabel.frame.origin.x,
                                    _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 3.f,
                                    _titleLabel.frame.size.width, 16.f);
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
        _addButton.userInteractionEnabled = YES;
        [_addButton addTarget:self action:@selector(queueSong:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_addButton];
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

- (void)queueSong:(UIButton *)button {
    [[ParseRoomManager shared] queueSongWithSpotifyId:_objectId
                                           completion:^(BOOL succeeded, NSError * _Nonnull error) {
        if (succeeded) {
            [button setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
        }
    }];
}

@end
