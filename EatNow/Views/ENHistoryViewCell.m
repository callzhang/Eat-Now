//
//  ENHistoryViewCell.m
//  EatNow
//
//  Created by Lee on 4/16/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENHistoryViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AMRatingControl.h"
@interface ENHistoryViewCell()
@property (nonatomic, strong) UIView *shadowView;
@end

@implementation ENHistoryViewCell

- (void)awakeFromNib {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.background.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:0.4].CGColor;
    self.background.layer.borderWidth = 1;
    
    self.shadowView = [[UIView alloc] initWithFrame:CGRectZero];
    self.shadowView.layer.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1].CGColor;
    self.shadowView.layer.shadowRadius = 2;
    self.shadowView.layer.shadowOpacity = 0.5;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 1);
    [self.contentView insertSubview:self.shadowView atIndex:0];
}

- (void)layoutSubviews {
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.background.frame cornerRadius:15].CGPath;
}

- (void)setRestaurant:(ENRestaurant *)restaurant{
    _restaurant = restaurant;
    [self.background setImageWithURL:[NSURL URLWithString:self.restaurant.imageUrls.firstObject]];
    self.title.text = _restaurant.name;
    self.subTitile.text = _restaurant.cuisineText;
}

- (void)setRate:(NSInteger)rate{
    //rating
    UIImage *emptyImageOrNil = [UIImage imageNamed:@"eat-now-card-details-view-rating-star-grey"];
    UIImage *solidImageOrNil = [UIImage imageNamed:@"eat-now-card-details-view-rating-star-yellow"];
    AMRatingControl *imagesRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0)
                                                                          emptyImage:emptyImageOrNil
                                                                          solidImage:solidImageOrNil
                                                                        andMaxRating:5];
    [imagesRatingControl setStarSpacing:3];
    imagesRatingControl.rating = rate + 3;
    [self.rating addSubview:imagesRatingControl];
}

@end

@implementation ENFoursquareViewCell


- (IBAction)onFoursqureButton:(id)sender {
    if (self.restaurant.venderUrl) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.restaurant.venderUrl]];
    }
}
@end