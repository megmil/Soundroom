//
//  SongCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SongCell.h"
#import "QueueSong.h"

@implementation SongCell {
    UILabel *_titleLabel;
    UILabel *_artistLabel;
    UIImageView *_albumImageView;
    
    UIButton *_addButton;
    
    UIButton *_upvoteButton;
    UIButton *_downvoteButton;
    UILabel *_scoreLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _albumImageView.frame = CGRectMake(20.f, 8.f, 50.f, 50.f);
    _addButton.frame = CGRectMake(self.contentView.frame.size.width - 50.f - 20.f, 8.f, 50.f, 50.f);
    
    CGFloat imageToLabels = _albumImageView.frame.origin.x + _albumImageView.frame.size.width + 8.f; // TODO: rename
    CGFloat labelsToButton = _addButton.frame.origin.x + 8.f; // TODO: rename
    
    _titleLabel.frame = CGRectMake(imageToLabels, _albumImageView.frame.origin.y + 6.f, labelsToButton - imageToLabels, 19.f);
    _artistLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 3.f, _titleLabel.frame.size.width, 16.f);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _albumImageView = [UIImageView new];
        _albumImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_albumImageView];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
        _titleLabel.numberOfLines = 1;
        [self.contentView addSubview:_titleLabel];
        
        _artistLabel = [UILabel new];
        _artistLabel.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightMedium];
        _artistLabel.textColor = [UIColor systemGray2Color];
        _artistLabel.numberOfLines = 1;
        [self.contentView addSubview:_artistLabel];
        
        _addButton = [UIButton new];
        _addButton.userInteractionEnabled = YES;
        [_addButton addTarget:self action:@selector(queueSong:) forControlEvents:UIControlEventTouchUpInside];
        [_addButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        [self.contentView addSubview:_addButton];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setArtist:(NSString *)artist {
    _artistLabel.text = artist;
}

- (void)setAlbumImage:(UIImage *)albumImage {
    _albumImageView.image = albumImage;
}

- (void)queueSong:(UIButton *)button {
    [QueueSong queueSongWithSpotifyId:_spotifyId completion:^(BOOL succeeded, NSError * _Nonnull error) {
        if (succeeded) {
            [button setImage:[UIImage systemImageNamed:@"checkmark"] forState:UIControlStateNormal];
        }
    }];
}

@end
