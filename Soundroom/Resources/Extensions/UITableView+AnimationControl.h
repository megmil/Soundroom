//
//  UITableView+UITableView_AnimationControl.h
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (AnimationControl)

- (void)reloadDataWithAnimation;
- (void)insertCellAtIndex:(NSUInteger)index;
- (void)removeCellAtIndex:(NSUInteger)index;
- (void)moveCellAtIndex:(NSUInteger)pastIndex toIndex:(NSUInteger)newIndex;

@end

NS_ASSUME_NONNULL_END
