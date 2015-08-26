//
//  UIStoryBoard+Extensions.m
//
//  Created by Zitao Xiong on 21/09/2014.
//  Copyright (c) 2014 Nanaimostudio. All rights reserved.
//

#import "UIWindow+Extensions.h"
#import "AppDelegate.h"

@implementation UIWindow (Extensions)
+ (UIWindow *)mainWindow {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    return delegate.window;
}

@end
