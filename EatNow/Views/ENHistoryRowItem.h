//
//  ENHistoryRowItem.h
//  EatNow
//
//  Created by Zitao Xiong on 4/29/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "TMRowItem.h"
#import "ENRestaurant.h"

@interface ENHistoryRowItem : TMRowItem
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (nonatomic, strong) NSNumber *rate;
@end
