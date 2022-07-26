//
//  ConfigureView.m
//  Soundroom
//
//  Created by Megan Miller on 7/12/22.
//

#import "ConfigureView.h"
@import SkyFloatingLabelTextField;

@implementation ConfigureView {
    
    UILabel *_headerLabel;
    SkyFloatingLabelTextField *_titleField;
    
    UIImageView *_modeImageView;
    UIImageView *_inviteImageView;
    UIImageView *_cleanImageView;
    
    UILabel *_modeTitleLabel;
    UILabel *_modeSubtitleLabel;
    UILabel *_inviteLabel;
    UILabel *_cleanLabel;
    
    UISwitch *_modeSwitch;
    UIButton *_inviteButton;
    UISwitch *_cleanSwitch;
    
    UIButton *_createButton;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_headerLabel sizeToFit];
    
    const CGFloat viewWidth = self.frame.size.width;
    
    const CGFloat widePadding = 20.f;
    const CGFloat standardPadding = 15.f;
    const CGFloat heavyPadding = widePadding + standardPadding;
    const CGFloat topPadding = 50.f;
    
    const CGFloat headerLabelWidth = _headerLabel.frame.size.width;
    const CGFloat headerLabelHeight = _headerLabel.frame.size.height;
    const CGFloat switchHeight = 31.f;
    const CGFloat switchWidth = 51.f;
    const CGFloat standardSize = 50.f;
    
    const CGFloat labelHeight = 20.f;
    const CGFloat titleHeight = 19.f;
    const CGFloat subtitleHeight = 16.f;
    const CGFloat labelsPadding = 3.f;
    
    const CGFloat titleAndSubtitleYOffsetFromImageView = (standardSize - (titleHeight + subtitleHeight + labelsPadding)) / 2.f;
    const CGFloat labelYOffsetFromImageView = (standardSize - labelHeight) / 2.f;
    const CGFloat switchYOffsetFromImageView = (standardSize - switchHeight) / 2.f;
    
    _headerLabel.frame = CGRectMake(widePadding, topPadding, headerLabelWidth, headerLabelHeight);
    
    const CGFloat titleFieldOriginY = CGRectGetMaxY(_headerLabel.frame) + widePadding;
    const CGFloat wideWidth = viewWidth - (widePadding * 2.f);
    
    _titleField.frame = CGRectMake(widePadding, titleFieldOriginY, wideWidth, standardSize);
    
    const CGFloat imageViewRightAlignmentOriginX = viewWidth - standardSize - heavyPadding;
    const CGFloat modeImageViewOriginY = CGRectGetMaxY(_titleField.frame) + heavyPadding;
    
    _modeImageView.frame = CGRectMake(heavyPadding, modeImageViewOriginY, standardSize, standardSize);
    
    const CGFloat modeSwitchOriginY = CGRectGetMinY(_modeImageView.frame) + switchYOffsetFromImageView;
    const CGFloat labelsOriginX = CGRectGetMaxX(_modeImageView.frame) + standardPadding;
    const CGFloat inviteImageViewOriginY = CGRectGetMaxY(_modeImageView.frame) + heavyPadding;
    const CGFloat modeTitleLabelOriginY = CGRectGetMinY(_modeImageView.frame) + titleAndSubtitleYOffsetFromImageView;
    
    _modeSwitch.frame = CGRectMake(imageViewRightAlignmentOriginX, modeSwitchOriginY, 0, 0);
    _inviteImageView.frame = CGRectMake(heavyPadding, inviteImageViewOriginY, standardSize, standardSize);
    _inviteButton.frame = CGRectMake(imageViewRightAlignmentOriginX, inviteImageViewOriginY, standardSize, standardSize);
    
    const CGFloat labelWidth = CGRectGetMinX(_modeSwitch.frame) - standardPadding - labelsOriginX;
    const CGFloat cleanImageViewOriginY = CGRectGetMaxY(_inviteImageView.frame) + heavyPadding;
    const CGFloat inviteLabelOriginY = CGRectGetMinY(_inviteImageView.frame) + labelYOffsetFromImageView;
    
    _modeTitleLabel.frame = CGRectMake(labelsOriginX, modeTitleLabelOriginY, labelWidth, titleHeight);
    _cleanImageView.frame = CGRectMake(heavyPadding, cleanImageViewOriginY, standardSize, standardSize);
    
    const CGFloat modeSubtitleLabelOriginY = CGRectGetMaxY(_modeTitleLabel.frame) + labelsPadding;
    const CGFloat createButtonOriginY = CGRectGetMaxY(_cleanImageView.frame) + heavyPadding;
    const CGFloat cleanLabelOriginY = CGRectGetMinY(_cleanImageView.frame) + labelYOffsetFromImageView;
    const CGFloat cleanSwitchOriginY = CGRectGetMinY(_cleanImageView.frame) + switchYOffsetFromImageView;
    
    _modeSubtitleLabel.frame = CGRectMake(labelsOriginX, modeSubtitleLabelOriginY, labelWidth, subtitleHeight);
    _inviteLabel.frame = CGRectMake(labelsOriginX, inviteLabelOriginY, labelWidth, labelHeight);
    _cleanLabel.frame = CGRectMake(labelsOriginX, cleanLabelOriginY, labelWidth, labelHeight);
    _cleanSwitch.frame = CGRectMake(imageViewRightAlignmentOriginX, cleanSwitchOriginY, 0, 0);
    _createButton.frame = CGRectMake(widePadding, createButtonOriginY, wideWidth, standardSize);
    
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    
    self = [super initWithCoder:coder];
    
    if (self) {
        
        _headerLabel = [UILabel new];
        _headerLabel.text = @"Create room";
        _headerLabel.font = [UIFont systemFontOfSize:26.f weight:UIFontWeightSemibold];
        _headerLabel.numberOfLines = 1;
        [self addSubview:_headerLabel];
        
        _titleField = [SkyFloatingLabelTextField new];
        _titleField.title = @"Room name";
        _titleField.titleFont = [UIFont systemFontOfSize:14.f];
        _titleField.titleColor = [UIColor systemGray2Color];
        _titleField.placeholder = @"Name your room";
        _titleField.placeholderFont = [UIFont systemFontOfSize:18.f];
        _titleField.placeholderColor = [UIColor systemGray2Color];
        _titleField.lineColor = _headerLabel.textColor;
        [self addSubview:_titleField];
        
        _modeImageView = [UIImageView new];
        _modeImageView.backgroundColor = [UIColor redColor];
        // TODO: get mode image
        [self addSubview:_modeImageView];
        
        _modeTitleLabel = [UILabel new];
        _modeTitleLabel.text = @"Party mode";
        _modeTitleLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
        _modeTitleLabel.numberOfLines = 1;
        [self addSubview:_modeTitleLabel];
        
        _modeSubtitleLabel = [UILabel new];
        _modeSubtitleLabel.text = @"Everyone is in the same room";
        _modeSubtitleLabel.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightRegular];
        _modeSubtitleLabel.textColor = [UIColor systemGray2Color];
        _modeSubtitleLabel.numberOfLines = 1;
        [self addSubview:_modeSubtitleLabel];
        
        _modeSwitch = [UISwitch new];
        _modeSwitch.on = NO;
        _modeSwitch.userInteractionEnabled = NO;
        [self addSubview:_modeSwitch];
        
        _inviteImageView = [UIImageView new];
        _inviteImageView.backgroundColor = [UIColor blueColor];
        // TODO: get invite image
        [self addSubview:_inviteImageView];
        
        _inviteLabel = [UILabel new];
        _inviteLabel.text = @"Invite members";
        _inviteLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
        _inviteLabel.numberOfLines = 1;
        [self addSubview:_inviteLabel];
        
        _inviteButton = [UIButton new];
        [_inviteButton setImage:[UIImage systemImageNamed:@"plus"] forState:UIControlStateNormal];
        _inviteButton.userInteractionEnabled = YES;
        [_inviteButton addTarget:self action:@selector(inviteMembers:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_inviteButton];
        
        _cleanImageView = [UIImageView new];
        _cleanImageView.backgroundColor = [UIColor greenColor];
        // TODO: get clean image
        [self addSubview:_cleanImageView];
        
        _cleanLabel = [UILabel new];
        _cleanLabel.text = @"Allow explicit songs";
        _cleanLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
        _cleanLabel.numberOfLines = 1;
        [self addSubview:_cleanLabel];
        
        _cleanSwitch = [UISwitch new];
        _cleanSwitch.on = YES;
        _cleanSwitch.userInteractionEnabled = NO;
        [self addSubview:_cleanSwitch];
        
        _createButton = [UIButton new];
        _createButton.titleLabel.text = @"Create";
        _createButton.backgroundColor = [UIColor purpleColor];
        [_createButton addTarget:self action:@selector(createRoom:) forControlEvents:UIControlEventTouchUpInside]; // TODO: remove colon?
        [self addSubview:_createButton];
        
    }
    
    return self;
}

- (NSString *)title {
    return _titleField.text;
}

- (void)createRoom:(UIButton *)button {
    [self.delegate createRoom];
}

- (void)inviteMembers:(UIButton *)button {
    [self.delegate inviteMembers];
}

@end
