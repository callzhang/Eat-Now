//
//  UITableView+RegisterRowItem.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "UITableView+RegisterRowItem.h"
#import "TMRowItem.h"

@implementation UITableView (RegisterRowItem)

//TODO: separate reuseIdentifier and nib name
- (void)registerRowItem:(TMRowItem *)rowItem {
    if ([rowItem reuseIdentifier]) {
        [self registerNib:[UINib nibWithNibName:[rowItem reuseIdentifier] bundle:nil] forCellReuseIdentifier:[rowItem reuseIdentifier]];
    }
}

- (void)registerRowItemClass:(Class)aClass {
    if ([aClass isSubclassOfClass:[TMRowItem class]]) {
        NSString *identifier = [aClass reuseIdentifier];
        NSParameterAssert(identifier);
        [self registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
    }
}
@end
