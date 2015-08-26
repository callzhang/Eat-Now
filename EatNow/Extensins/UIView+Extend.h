//
//  UIView+Extend.h
//  EatNow
//
//  Created by Lei Zhang on 4/19/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extend)
- (void)applyShadow;
- (void)applyAlphaGradientWithEndPoints:(NSArray *)locations;
//- (void)applyGredient;
//- (void)applyGredient2;

/**
 *  Render current view to an UIImage
 *
 *  @return An UIImage
 */
- (UIImage *)toImage;

@end
