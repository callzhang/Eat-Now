//
//  UITableView+RegisterRowItem.h
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TMRowItem;
@interface UITableView (RegisterRowItem)
- (void)registerRowItem:(TMRowItem *)rowItem;
- (void)registerRowItemClass:(Class)aClass;
@end
