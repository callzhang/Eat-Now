//
//  UIView+Material.h
//  MaterialView
//
//  Created by Zitao Xiong on 4/18/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EWBlockTypes.h"

@interface UIView (Material)
+ (void)collapse:(UIView *)button view:(UIView *)view;
+ (void)expand:(UIView *)button view:(UIView *)view completion:(VoidBlock)block;
+ (void)collapse:(UIView *)button view:(UIView *)view animated:(BOOL)animated completion:(VoidBlock)block;
+ (void)expand:(UIView *)button view:(UIView *)view animated:(BOOL)animated completion:(VoidBlock)block;
@end
