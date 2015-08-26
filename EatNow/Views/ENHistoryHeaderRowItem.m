//
//  ENHistoryHeaderRowItem.m
//  EatNow
//
//  Created by Zitao Xiong on 4/29/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENHistoryHeaderRowItem.h"
#import "NSDate+Extension.h"

@implementation ENHistoryHeaderRowItem
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.heightForRow = 60;
    }
    return self;
}

+ (NSString *)reuseIdentifier {
    return @"sectionHeader";
}

- (UITableViewCell *)cellForRow {
    UITableViewCell *cell = [super cellForRow];
    UILabel *label = (id)[cell.contentView viewWithTag:89];
    
    label.text = self.date.string;
    return cell;
}
@end
