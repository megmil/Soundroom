//
//  RoomCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomCell.h"
#import "ParseObjectManager.h"

@implementation RoomCell {
    
    UILabel *_titleLabel;
    UIImageView *_imageView;
    
    UIButton *_acceptButton;
    UIButton *_rejectButton;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    const CGFloat imageSize = 60.f;
    const CGFloat buttonSize = 32.f;
    
    const CGFloat viewHeight = self.contentView.frame.size.height;
    const CGFloat viewWidth = self.contentView.frame.size.width;
    
    const CGFloat padding = 15.f;
    const CGFloat imageTopPadding = 8.f;
    const CGFloat sidePadding = 20.f;
    const CGFloat rightSideLimit = viewWidth - sidePadding;
    const CGFloat buttonTopPadding = (viewHeight - buttonSize) / 2.f;
    
    _imageView.frame = CGRectMake(sidePadding, imageTopPadding, imageSize, imageSize);
    _rejectButton.frame = CGRectMake(rightSideLimit - buttonSize, buttonTopPadding, buttonSize, buttonSize);
    
    const CGFloat acceptButtonOriginX = CGRectGetMinX(_rejectButton.frame) - buttonSize - padding;
    
    _acceptButton.frame = CGRectMake(acceptButtonOriginX, buttonTopPadding, buttonSize, buttonSize);
    
    [_titleLabel sizeToFit];
    
    const CGFloat titleLabelOriginX = CGRectGetMaxX(_imageView.frame) + padding;
    const CGFloat titleLabelOriginY = CGRectGetMinY(_imageView.frame) + (( imageSize - CGRectGetHeight(_titleLabel.frame) ) / 2.f);
    const CGFloat titleLabelWidth = CGRectGetMinX(_acceptButton.frame) - padding - titleLabelOriginX;

    _titleLabel.frame = CGRectMake(titleLabelOriginX, titleLabelOriginY, titleLabelWidth, _titleLabel.frame.size.height);
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.backgroundColor = [UIColor purpleColor];
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightRegular];
        _titleLabel.numberOfLines = 1;
        [self.contentView addSubview:_titleLabel];
        
        _acceptButton = [UIButton new];
        _acceptButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        _acceptButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        [_acceptButton setImage:[UIImage systemImageNamed:@"checkmark.circle"] forState:UIControlStateNormal];
        [_acceptButton addTarget:self action:@selector(didTapAcceptInvitation) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_acceptButton];
        
        _rejectButton = [UIButton new];
        _rejectButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
        _rejectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
        [_rejectButton setImage:[UIImage systemImageNamed:@"multiply.circle"] forState:UIControlStateNormal];
        [_rejectButton addTarget:self action:@selector(didTapRejectInvitation) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_rejectButton];
        
    }
    
    return self;
}

- (void)didTapAcceptInvitation {
    [ParseObjectManager acceptInvitationWithId:_objectId];
}

- (void)didTapRejectInvitation {
    [ParseObjectManager deleteInvitationWithId:_objectId];
}

# pragma mark - Setters

- (void)setTitle:(NSString *)title {
    _titleLabel.text = title;
}

- (void)setImage:(UIImage *)image {
    _imageView.image = image;
}

- (void)setCellType:(RoomCellType)cellType {
    
    _cellType = cellType;
    
    BOOL isInvitationCell = cellType == InvitationCell;
    
    [_acceptButton setHidden:!isInvitationCell];
    [_rejectButton setHidden:!isInvitationCell];
    
}

@end
