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
    UILabel *_modeLabel;
    UILabel *_modeDescription;
    
    UIImageView *_inviteImageView;
    UILabel *_inviteLabel;
    UIButton *_inviteButton;
    
    UIImageView *_cleanImageView;
    UILabel *_cleanLabel;
    UISwitch *_cleanSwitch;
    
    UIButton *_createButton;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_headerLabel sizeToFit];
    _headerLabel.frame = CGRectMake(20.f, 50.f, _headerLabel.frame.size.width, _headerLabel.frame.size.height);
    _titleField.frame = CGRectMake(20.f, _headerLabel.frame.origin.y + _headerLabel.frame.size.height + 20.f, self.frame.size.width - 40.f, 50.f);
    
    _modeImageView.frame = CGRectMake(35.f, _titleField.frame.origin.y + _titleField.frame.size.height + 35.f, 50.f, 50.f);
    _modeLabel.frame = CGRectMake(_modeImageView.frame.origin.x + _modeImageView.frame.size.width + 14.f, _modeImageView.frame.origin.y + 6.f, 200.f, 19.f);
    _modeDescription.frame = CGRectMake(_modeLabel.frame.origin.x, _modeLabel.frame.origin.y + _modeLabel.frame.size.height + 3.f, 200.f, 16.f);
    
    _inviteImageView.frame = CGRectMake(35.f, _modeImageView.frame.origin.y + _modeImageView.frame.size.height + 35.f, 50.f, 50.f);
    _inviteLabel.frame = CGRectMake(_inviteImageView.frame.origin.x + _inviteImageView.frame.size.width + 14.f, _inviteImageView.frame.origin.y + 15.f, 200.f, 20.f);
    _inviteButton.frame = CGRectMake(self.frame.size.width - 50.f - 35.f, _inviteImageView.frame.origin.y, 50.f, 50.f);
    
    _cleanImageView.frame = CGRectMake(35.f, _inviteImageView.frame.origin.y + _inviteImageView.frame.size.height + 35.f, 50.f, 50.f);
    _cleanLabel.frame = CGRectMake(_cleanImageView.frame.origin.x + _cleanImageView.frame.size.width + 14.f, _cleanImageView.frame.origin.y + 15.f, 200.f, 20.f);
    _cleanSwitch.frame = CGRectMake(self.frame.size.width - 50.f - 35.f, _cleanImageView.frame.origin.y + 10.f, 0, 0); // height: 31, width: 51
    
    _createButton.frame = CGRectMake(_titleField.frame.origin.x, _cleanImageView.frame.origin.y + _cleanImageView.frame.size.height + 35.f, _titleField.frame.size.width, 50.f);
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
        _titleField.placeholder = @"Name your room";
        _titleField.font = [UIFont systemFontOfSize:18.f];
        [self addSubview:_titleField];
        
        _modeImageView = [UIImageView new];
        _modeImageView.backgroundColor = [UIColor redColor];
        // TODO: get mode image
        [self addSubview:_modeImageView];
        
        _modeLabel = [UILabel new];
        _modeLabel.text = @"Party mode";
        _modeLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightMedium];
        _modeLabel.numberOfLines = 1;
        [self addSubview:_modeLabel];
        
        _modeDescription = [UILabel new];
        _modeDescription.text = @"Everyone is in the same room";
        _modeDescription.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightRegular];
        _modeDescription.textColor = [UIColor systemGray2Color];
        _modeDescription.numberOfLines = 1;
        [self addSubview:_modeDescription];
        
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
    [self.delegate didCreateRoom];
}

- (void)inviteMembers:(UIButton *)button {
    
}

@end
