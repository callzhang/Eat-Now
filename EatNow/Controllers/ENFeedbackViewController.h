//
//  ENFeedbackViewController.h
//  EatNow
//
//  Created by Zitao Xiong on 5/2/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENRestaurant.h"
#import "ENRestaurantViewController.h"


@class ENMainViewController;
@interface ENFeedbackViewController : UIViewController<ENCardViewControllerProtocol>
/**
 *  @{_id: id, restaurant: restaurant, like: float, date: NSDate}
 */
@property (nonatomic, strong) NSDictionary *history;
@property (nonatomic, weak) ENMainViewController *mainViewController;

+ (instancetype)viewController;
- (UIView *)shadowView;
@end
