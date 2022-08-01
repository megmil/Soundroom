//
//  ShimmerLayer.m
//  Soundroom
//
//  Created by Megan Miller on 7/27/22.
//

#import "ShimmerLayer.h"

@implementation ShimmerLayer

static NSString *const animationKeyPath = @"locations";

static NSArray <NSNumber *> *const startLocations = @[@-1, @-0.5, @0];
static NSArray <NSNumber *> *const endLocations = @[@1, @1.5, @2];

static const CGFloat roundCornerSize = 5.f;
static const CGFloat movingAnimationDuration = 1.8f;
static const CGFloat delayBetweenAnimationLoops = 1.5f;

- (void)maskWithViews:(NSArray <UIView *> *)views frame:(CGRect)frame {
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    
    // apply image view, title label, and subtitle label as a mask
    CGMutablePathRef mutablePath = CGPathCreateMutable();
    for (UIView *view in views) {
        CGPathAddRoundedRect(mutablePath, nil, view.frame, roundCornerSize, roundCornerSize);
    }
    maskLayer.path = mutablePath;
    
    UIColor *backgroundColor = [UIColor tertiarySystemFillColor];
    UIColor *movingColor = [UIColor secondarySystemFillColor];
    
    self.mask = maskLayer;
    self.frame = frame;
    self.startPoint = CGPointMake(0.f, 1.f);
    self.endPoint = CGPointMake(1.f, 1.f);
    self.colors = @[(id)backgroundColor.CGColor, (id)movingColor.CGColor, (id)backgroundColor.CGColor];
    self.locations = startLocations;
    
}

- (void)setIsAnimating:(BOOL)isAnimating {
    
    self.opacity = isAnimating ? 1 : 0;
    
    if (isAnimating && [self animationForKey:animationKeyPath]) {
        return;
    }
    
    [self removeAnimationForKey:animationKeyPath];
    if (isAnimating) {
        [self startAnimating];
    }
    
}

- (void)startAnimating {
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:animationKeyPath];
    animation.fromValue = startLocations;
    animation.toValue = endLocations;
    animation.duration = movingAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimationGroup *animationGroup = [[CAAnimationGroup alloc] init];
    animationGroup.duration = movingAnimationDuration + delayBetweenAnimationLoops;
    animationGroup.animations = @[animation];
    animationGroup.repeatCount = INFINITY;
    [self addAnimation:animationGroup forKey:animationKeyPath];

}

@end
