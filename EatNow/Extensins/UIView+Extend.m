//
//  UIView+Extend.m
//  EatNow
//
//  Created by Lei Zhang on 4/19/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "UIView+Extend.h"

@implementation UIView (Extend)
- (void)applyShadow{
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    float op = 0.2;
    float r = 5;
    if ([self isKindOfClass:[UILabel class]]) {
        op = 1.0;
        r = 3;
    }
    self.layer.shadowOpacity = op;
    self.layer.shadowRadius = r;
    self.layer.shadowOffset = CGSizeMake(0,0);
    self.clipsToBounds = NO;
}

- (void)applyAlphaGradientWithEndPoints:(NSArray *)locations{
    //alpha mask
    UIView *mask = [[UIView alloc] initWithFrame:self.frame];
    [self.superview insertSubview:mask aboveSubview:self];
    [mask addSubview:self];
    self.frame = mask.bounds;
    mask.backgroundColor = [UIColor clearColor];
    
    CAGradientLayer *alphaMask = [CAGradientLayer layer];
    alphaMask.anchorPoint = CGPointZero;
    alphaMask.startPoint = CGPointZero;
    alphaMask.endPoint = CGPointMake(0.0f, 1.0f);
    UIColor *startColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    UIColor *endColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    NSArray *endPoints;
    NSArray *colors;
    NSParameterAssert(locations.count <= 2);
    if (locations.count == 1) {
        endPoints = @[@0.0, locations[0], @1.0];
        colors = @[(id)startColor.CGColor, (id)endColor.CGColor, (id)endColor.CGColor];
    }else if (locations.count == 2){
        endPoints = @[@0.0, locations[0], locations[1], @1.0];
        colors = @[(id)startColor.CGColor, (id)endColor.CGColor, (id)endColor.CGColor, (id)startColor.CGColor];
    }
    alphaMask.colors = colors;
    alphaMask.locations =endPoints;
    alphaMask.bounds = CGRectMake(0, 0, mask.frame.size.width, mask.frame.size.height);
    
    mask.layer.mask = alphaMask;

}

- (void)applyGredient{
    // the colors
    CGColorRef topColor = [[UIColor colorWithWhite:0 alpha:0.5] CGColor];
    CGColorRef bottomColor = [[UIColor colorWithWhite:0 alpha:0.0] CGColor];
    NSArray *colors = @[(__bridge id)topColor, (__bridge id)bottomColor];
    NSArray *locations = @[@0, @1];
    
    // draw
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.locations = locations;
    gradientLayer.frame = self.bounds;
    [self.layer addSublayer:gradientLayer];
}

- (void)applyGredient2{
    // the colors
    CGColorRef topColor = [[UIColor colorWithWhite:0 alpha:0.5] CGColor];
    CGColorRef bottomColor = [[UIColor colorWithWhite:0 alpha:0] CGColor];
    NSArray *colors = @[(__bridge id)topColor, (__bridge id)bottomColor, (__bridge id)topColor];
    NSArray *locations = @[@0, @0.5, @1];
    
    // draw
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.locations = locations;
    gradientLayer.frame = self.bounds;
    [self.layer addSublayer:gradientLayer];
}

- (UIImage *)toImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}


@end
