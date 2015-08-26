//
//  UIView+screenshot.m
//  EatNow
//
//  Created by Lee on 7/15/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "UIView+screenshot.h"

@implementation UIView (screenshot)

- (UIImage *)screenshot{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    //DDLogVerbose(@"Window scale: %f", self.window.screen.scale);
    /* iOS 7 */
    BOOL visible = !self.hidden && self.superview;
    CGFloat alpha = self.alpha;
    BOOL animating = self.layer.animationKeys != nil;
    BOOL success = YES;
    if ([self respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]){
        //only works when visible
        if (!animating && alpha == 1 && visible) {
            success = [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
        }else{
            self.alpha = 1;
            success = [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
            self.alpha = alpha;
        }
    }
    if(!success){ /* iOS 6 */
        self.alpha = 1;
        [self.layer renderInContext:UIGraphicsGetCurrentContext()];
        self.alpha = alpha;
    }
    
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

@end
