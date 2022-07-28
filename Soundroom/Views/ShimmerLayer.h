//
//  ShimmerLayer.h
//  Soundroom
//
//  Created by Megan Miller on 7/27/22.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShimmerLayer : CAGradientLayer

- (void)maskWithViews:(NSArray <UIView *> *)views frame:(CGRect)frame;
- (void)startAnimating;
- (void)stopAnimating;

@end

NS_ASSUME_NONNULL_END
