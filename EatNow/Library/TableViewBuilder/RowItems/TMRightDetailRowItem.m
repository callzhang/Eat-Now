//
//  TMRightDetailRowItem.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMRightDetailRowItem.h"
#import "TMRightDetailTableViewCell.h"
#import "FBKVOController+Binding.h"
#import "extobjc.h"

@implementation TMRightDetailRowItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.heightForRow = 44;
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return @"TMRightDetailTableViewCell";
}

- (UITableViewCell *)cellForRow {
    TMRightDetailTableViewCell *cell = (id) [super cellForRow];
    [self bindKeypath:@keypath(self.text) toLabel:cell.cellTextLabel];
    [self bindKeypath:@keypath(self.detailText) toLabel:cell.cellDetailLabel];
    return cell;
}
@end
