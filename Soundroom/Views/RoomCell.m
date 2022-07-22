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
    
    const CGFloat imageSize = 50.f;
    const CGFloat buttonSize = 30.f;
    
    const CGFloat viewHeight = self.contentView.frame.size.height;
    const CGFloat viewWidth = self.contentView.frame.size.width;
    
    const CGFloat padding = 8.f;
    const CGFloat leftSidePadding = 20.f;
    const CGFloat rightSidePadding = viewWidth - leftSidePadding;
    const CGFloat buttonTopPadding = (viewHeight - (buttonSize + (padding * 2.f))) / 2.f;
    
    _imageView.frame = CGRectMake(leftSidePadding, padding, imageSize, imageSize);
    _rejectButton.frame = CGRectMake(rightSidePadding - buttonSize, buttonTopPadding, buttonSize, buttonSize);
    
    CGFloat acceptButtonOriginX = CGRectGetMinX(_rejectButton.frame) - padding;
    
    _acceptButton.frame = CGRectMake(acceptButtonOriginX, buttonTopPadding, buttonSize, buttonSize);
    
    [_titleLabel sizeToFit];
    
    const CGFloat titleLabelOriginX = CGRectGetMaxX(_imageView.frame) + padding;
    const CGFloat titleLabelOriginY = CGRectGetMinY(_imageView.frame) - (( CGRectGetHeight(_imageView.frame) - CGRectGetHeight(_titleLabel.frame) ) / 2.f);
    const CGFloat titleLabelWidth = CGRectGetMinX(_acceptButton.frame) - padding - titleLabelOriginX;

    _titleLabel.frame = CGRectMake(titleLabelOriginX, titleLabelOriginY, titleLabelWidth, _titleLabel.frame.size.height);
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        _imageView = [UIImageView new];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:17.f weight:UIFontWeightRegular];
        _titleLabel.numberOfLines = 1;
        [self.contentView addSubview:_titleLabel];
        
        _acceptButton = [UIButton new];
        [_acceptButton setImage:[UIImage systemImageNamed:@"checkmark.circle"] forState:UIControlStateNormal];
        [_acceptButton addTarget:self action:@selector(didTapAcceptInvitation) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_acceptButton];
        
        _rejectButton = [UIButton new];
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
