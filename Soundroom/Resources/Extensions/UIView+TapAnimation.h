//
//  UIView+TapAnimation.h
//  Soundroom
//
//  Created by Megan Miller on 8/10/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ScaleSize) {
    Small = 0,
    Large = 1
};

@interface UIView (TapAnimation)

- (void)animateWithScaleSize:(ScaleSize)scaleSize completion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
