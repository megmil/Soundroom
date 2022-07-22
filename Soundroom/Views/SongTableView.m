//
//  SongTableView.m
//  Soundroom
//
//  Created by Megan Miller on 7/22/22.
//

#import "SongTableView.h"

@implementation SongTableView

- (void)reloadData {
    
    [super reloadData];
    
    CGFloat tableViewHeight = self.bounds.size.height;
    NSArray <UITableViewCell *> *cells = self.visibleCells;
    
    for (UITableViewCell *cell in cells) {
        cell.transform = CGAffineTransformMakeTranslation(0.f, tableViewHeight);
    }
    
    CGFloat delayCounter = 0.f;
    for (UITableViewCell *cell in cells) {
        [UIView animateWithDuration:1.5f
                              delay:0.08f * delayCounter
             usingSpringWithDamping:0.7f
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{ cell.transform = CGAffineTransformIdentity; }
                         completion:nil];
        delayCounter += 1;
    }
}

@end
