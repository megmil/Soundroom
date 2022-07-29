//
//  UITableView+EmptyMessage.h
//  Soundroom
//
//  Created by Megan Miller on 7/29/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (EmptyMessage)

- (void)showEmptyMessageWithText:(NSString *)text;
- (void)removeEmptyMessage;

@end

NS_ASSUME_NONNULL_END
