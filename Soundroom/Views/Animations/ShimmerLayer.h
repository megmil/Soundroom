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

@property (nonatomic) BOOL isAnimating;

- (void)maskWithViews:(NSArray <UIView *> *)views frame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
