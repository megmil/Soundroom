//
//  RoomCell.m
//  Soundroom
//
//  Created by Megan Miller on 7/5/22.
//

#import "RoomCell.h"
#import "ImageConstants.h"
#import "UIView+TapAnimation.h"

static const CGFloat imageSize = 60.f;
static const CGFloat imageCornerRadius = 0.06f * imageSize;

@implementation RoomCell {
    UILabel *_titleLabel;
    UIImageView *_imageView;
    UIButton *_acceptButton;
    UIButton *_rejectButton;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    const CGFloat buttonSize = 30.f;
    
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
    
    const CGFloat titleLabelHeight = _titleLabel.frame.size.height;
    const CGFloat titleLabelOriginX = CGRectGetMaxX(_imageView.frame) + padding;
    const CGFloat titleLabelOriginY = CGRectGetMinY(_imageView.frame) + ((imageSize - titleLabelHeight) / 2.f);
    const CGFloat titleLabelWidth = CGRectGetMinX(_acceptButton.frame) - padding - titleLabelOriginX;

    _titleLabel.frame = CGRectMake(titleLabelOriginX, titleLabelOriginY, titleLabelWidth, titleLabelHeight);
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        [self configureImageView];
        [self configureTitleLabel];
        [self configureAcceptButton];
        [self configureRejectButton];
        
    }
    
    return self;
}

- (void)configureImageView {
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.backgroundColor = [UIColor purpleColor];
    _imageView.layer.cornerRadius = imageCornerRadius;
    _imageView.clipsToBounds = YES;
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_imageView];
}

- (void)configureTitleLabel {
    _titleLabel = [UILabel new];
    _titleLabel.font = [UIFont systemFontOfSize:18.f weight:UIFontWeightRegular];
    [self.contentView addSubview:_titleLabel];
}

- (void)configureAcceptButton {
    _acceptButton = [UIButton new];
    _acceptButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _acceptButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [_acceptButton setImage:[UIImage systemImageNamed:acceptImageName] forState:UIControlStateNormal];
    [_acceptButton addTarget:self action:@selector(didTapAcceptInvitation) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_acceptButton];
}

- (void)configureRejectButton {
    _rejectButton = [UIButton new];
    _rejectButton.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    _rejectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    [_rejectButton setImage:[UIImage systemImageNamed:rejectImageName] forState:UIControlStateNormal];
    [_rejectButton addTarget:self action:@selector(didTapRejectInvitation) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_rejectButton];
}

- (void)didTapAcceptInvitation {
    [_acceptButton animateWithScaleSize:Large completion:^{
        [self->_delegate didTapAcceptInvitationWithId:self->_objectId];
    }];
}

- (void)didTapRejectInvitation {
    [_rejectButton animateWithScaleSize:Large completion:^{
        [self->_delegate didTapRejectInvitationWithId:self->_objectId];
    }];
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
    
    _acceptButton.hidden = !isInvitationCell;
    _rejectButton.hidden = !isInvitationCell;
    
}

@end
