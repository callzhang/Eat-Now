//
//  ENHistoryViewController.h
//  EatNow
//
//  Created by Lee on 4/16/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENMainViewController.h"

extern NSString *const kHistoryDetailCardDidShow;
extern NSString *const kHistoryTableViewDidShow;

@class ENRestaurantViewController;

@interface ENHistoryViewController : UITableViewController
@property (nonatomic, strong) ENRestaurantViewController *restaurantViewController;
@property (nonatomic, weak) ENMainViewController *mainViewController;
@property (nonatomic, strong) UIView *mainView;
- (void)loadData;
- (void)closeRestaurantView;
@end
