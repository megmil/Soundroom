//
//  UITableView+EmptyMessage.m
//  Soundroom
//
//  Created by Megan Miller on 7/29/22.
//

#import "UITableView+EmptyMessage.h"

@implementation UITableView (EmptyMessage)

- (void)showEmptyMessageWithText:(NSString *)text {
    
    UILabel *messageLabel = [UILabel new];
    messageLabel.frame = CGRectMake(0.f, 0.f, self.bounds.size.width, self.bounds.size.height);
    messageLabel.text = text;
    messageLabel.textColor = [UIColor labelColor];
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightRegular];
    [messageLabel sizeToFit];
    
    self.backgroundView = messageLabel;
    self.backgroundView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)removeEmptyMessage {
    self.backgroundView = nil;
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

@end
