//
//  UIView+Material.m
//  MaterialView
//
//  Created by Zitao Xiong on 4/18/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

#import "UIView+Material.h"
#define kAnimationDuration    0.5// match this to the value of the UIView animateWithDuration: call

@implementation UIView (Material)
+ (void)collapse:(UIView *)button view:(UIView *)view animated:(BOOL)animated completion:(VoidBlock)block {
    
    CGFloat radius = sqrtf(powf(button.frame.origin.x + button.frame.size.width / 2, 2) + powf(button.frame.origin.y + button.frame.size.height / 2, 2)) ;
    CGFloat scale = radius / MIN(button.bounds.size.width, button.bounds.size.height) * 3;
    CABasicAnimation *animation = [self shapeAnimationWithTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] scale:scale inflating:YES];
    
    CAShapeLayer *circle = [CAShapeLayer layer];
    circle.bounds = button.bounds;
    CGFloat toRadius = button.bounds.size.width / 2;
    circle.path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 2.0*toRadius, 2.0*toRadius)
                                             cornerRadius:radius].CGPath;
    circle.position = [button.superview convertPoint:CGPointMake(button.center.x, button.center.y) toView:view];
    //circle.position = CGPointMake(button.center.x, button.center.y);
    view.layer.mask = circle;
    
    if (!animated) {
        return;
    }
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:kAnimationDuration] forKey:kCATransactionAnimationDuration];
    
    [CATransaction setCompletionBlock:block];
    
    [circle addAnimation:animation forKey:@"shapeMaskAnimation"];
    [CATransaction commit];
    
}

+ (void)collapse:(UIView *)button view:(UIView *)view {
    [self collapse:button view:view animated:YES completion:nil];
}

+ (void)expand:(UIView *)button view:(UIView *)view animated:(BOOL)animated completion:(VoidBlock)block {
    
    
    CGFloat radius = sqrtf(powf(button.frame.origin.x + button.frame.size.width / 2, 2) + powf(button.frame.origin.y + button.frame.size.height / 2, 2)) ;
    CGFloat scale = radius / MIN(button.bounds.size.width, button.bounds.size.height) * 3;
    
    CABasicAnimation *animation = [self shapeAnimationWithTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut] scale:scale inflating:NO];
    animation.duration = kAnimationDuration;
    CAShapeLayer *cycle = (CAShapeLayer *)view.layer.mask;
    
    if (!animated) {
        [cycle removeFromSuperlayer];
        if (block) {
            block();
        }
        return;
    }
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:kAnimationDuration] forKey:kCATransactionAnimationDuration];
    
    [CATransaction setCompletionBlock:^{
        [cycle removeFromSuperlayer];
        if (block) {
            block();
        }
    }];
    [cycle addAnimation:animation forKey:@"shapeMaskAnimation"];
    
    [CATransaction setDisableActions:YES];
    view.layer.mask.transform = [animation.toValue CATransform3DValue];
 
    [CATransaction commit];
}

+ (void)expand:(UIView *)button view:(UIView *)view completion:(VoidBlock)block {
    [self expand:button view:view animated:YES completion:block];
}

+ (CABasicAnimation *)shapeAnimationWithTimingFunction:(CAMediaTimingFunction *)timingFunction scale:(CGFloat)scale inflating:(BOOL)inflating {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    if (inflating) {
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
    } else {
        animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(scale, scale, 1.0)];
        animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    }
    animation.timingFunction = timingFunction;
    animation.fillMode = kCAFillModeForwards;
//    animation.removedOnCompletion = YES;
    return animation;
}
@end
