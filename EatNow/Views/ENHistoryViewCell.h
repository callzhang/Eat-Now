//
//  ENHistoryViewCell.h
//  EatNow
//
//  Created by Lee on 4/16/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENRestaurant.h"

@interface ENHistoryViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subTitile;
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (weak, nonatomic) IBOutlet UIView *rating;
@property (nonatomic, assign) NSInteger rate;
@end

@interface ENFoursquareViewCell : UITableViewCell
@property (nonatomic, strong) ENRestaurant *restaurant;
@end