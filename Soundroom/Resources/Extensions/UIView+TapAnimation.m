//
//  UIView+TapAnimation.m
//  Soundroom
//
//  Created by Megan Miller on 8/10/22.
//

#import "UIView+TapAnimation.h"

static const CGFloat smallScaleSize = 0.95f;
static const CGFloat largeScaleSize = 0.85f;

@implementation UIView (TapAnimation)

- (void)animateWithScaleSize:(ScaleSize)scaleSize completion:(void (^)(void))completion {
    
    __weak UIView *weakSelf = self;
    CGFloat scale = (scaleSize == Large) ? largeScaleSize : smallScaleSize;
    
    self.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:0.1
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{ weakSelf.transform = CGAffineTransformMakeScale(scale, scale); }
                     completion:^(BOOL finished) {
        
                        if (finished) {
                            [UIView animateWithDuration:0.1
                                                  delay:0
                                                options:UIViewAnimationOptionCurveLinear
                                             animations:^{ weakSelf.transform = CGAffineTransformMakeScale(1.f, 1.f); }
                                             completion:^(BOOL finished) {
                                
                                                if (finished) {
                                                    self.userInteractionEnabled = YES;
                                                    completion();
                                                }
                                
                            }];
                        }
        
    }];
    
}

@end
