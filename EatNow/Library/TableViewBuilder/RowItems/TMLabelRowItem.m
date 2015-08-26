//
//  TMLabelRowItem.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMLabelRowItem.h"
#import "TMTextLabelTableViewCell.h"
#import "extobjc.h"
#import "FBKVOController+Binding.h"

@implementation TMLabelRowItem
+ (NSString *)reuseIdentifier {
    return NSStringFromClass([TMTextLabelTableViewCell class]);
}

- (UITableViewCell *)cellForRow {
    TMTextLabelTableViewCell *cell = (id) [super cellForRow];
    [self bindKeypath:@keypath(TMLabelRowItem.new, text) toLabel:cell.titleLabel];
    return cell;
}
@end
