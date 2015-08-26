//
//  ENHistoryRowItem.m
//  EatNow
//
//  Created by Zitao Xiong on 4/29/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENHistoryRowItem.h"
#import "ENHistoryViewCell.h"

@implementation ENHistoryRowItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.heightForRow = 100;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return @"historyCell";
}

- (UITableViewCell *)cellForRow {
    ENHistoryViewCell *cell = (id) [super cellForRow];
    cell.restaurant = self.restaurant;
//    cell.rate = [self.rate integerValue];
    return cell;
}
@end
