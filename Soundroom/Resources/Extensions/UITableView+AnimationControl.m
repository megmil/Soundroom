//
//  UITableView+UITableView_AnimationControl.m
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import "UITableView+AnimationControl.h"

@implementation UITableView (AnimationControl)

- (void)reloadDataWithAnimation {
    
    [self reloadData];
    
    CGFloat tableViewHeight = self.bounds.size.height;
    NSArray <UITableViewCell *> *cells = self.visibleCells;
    
    for (UITableViewCell *cell in cells) {
        cell.transform = CGAffineTransformMakeTranslation(0.f, tableViewHeight);
    }
    
    CGFloat delayCounter = 0.f;
    for (UITableViewCell *cell in cells) {
        [UIView animateWithDuration:1.2f
                              delay:0.1f * delayCounter
             usingSpringWithDamping:0.85f
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{ cell.transform = CGAffineTransformIdentity; }
                         completion:nil];
        delayCounter += 1;
    }
}

- (void)insertCellAtIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
}

- (void)moveCellAtIndex:(NSUInteger)pastIndex toIndex:(NSUInteger)newIndex {
    
    NSIndexPath *pastIndexPath = [NSIndexPath indexPathForRow:pastIndex inSection:0];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:newIndex inSection:0];
    
    if (pastIndex == newIndex) {
        [self reconfigureRowsAtIndexPaths:@[pastIndexPath]];
        return;
    }
    
    [self moveRowAtIndexPath:pastIndexPath toIndexPath:newIndexPath];
    [self reconfigureRowsAtIndexPaths:@[newIndexPath]];
    
}

- (void)deleteCellAtIndex:(NSUInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

@end
