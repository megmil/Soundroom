//
//  SongCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "SongCell.h"
#import "Song.h"

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
    
    _albumImageView.frame = CGRectMake(0.f, 0.f, 50.f, 50.f);
    
    _addButton.frame = CGRectMake(self.contentView.frame.size.width - 50.f, self.contentView.frame.size.height - 50.f, 50.f, 50.f);
    
    _titleLabel.frame = CGRectMake(_albumImageView.frame.size.width + 8.f, 6.f, (_addButton.frame.origin.x + 8.f) - (_albumImageView.frame.size.width + 8), 19.f);
    
    _artistLabel.frame = CGRectMake(_titleLabel.frame.origin.x, _titleLabel.frame.origin.y + 3.f, (_addButton.frame.origin.x + 8.f) - (_albumImageView.frame.size.width + 8), 16.f);
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
        [_addButton addTarget:nil action:@selector(queueSong) forControlEvents:UIControlEventTouchUpInside];
        _addButton.imageView.image = [UIImage systemImageNamed:@"plus"];
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

- (void)queueSong {
    // TODO: queue song with id
}

@end
