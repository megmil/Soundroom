//
//  UIView+TapAnimation.h
//  Soundroom
//
//  Created by Megan Miller on 8/10/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (TapAnimation)

- (void)animateWithCompletion:(void (^)(void))completion;

@end

NS_ASSUME_NONNULL_END
