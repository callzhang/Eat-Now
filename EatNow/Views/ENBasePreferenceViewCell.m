//
//  ENBasePreferenceViewCell.m
//  
//
//  Created by Lei Zhang on 7/12/15.
//
//

#import "ENBasePreferenceViewCell.h"
#import "AMRatingControl.h"
#import "extobjc.h"

@interface ENBasePreferenceViewCell()
@property (nonatomic, strong) AMRatingControl *cuisineScore;
@end

@implementation ENBasePreferenceViewCell
- (void)awakeFromNib{
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.rating.backgroundColor = [UIColor clearColor];
    
    UIImage *emptyImageOrNil = [UIImage imageNamed:@"eat-now-card-details-view-rating-star-grey"];
    UIImage *solidImageOrNil = [UIImage imageNamed:@"eat-now-card-details-view-rating-star-yellow"];
    self.cuisineScore = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0)
                                                       emptyImage:emptyImageOrNil
                                                       solidImage:solidImageOrNil
                                                     andMaxRating:5];
    [self.cuisineScore setStarSpacing:3];
    self.cuisineScore.rating = 0;
    [self.rating addSubview:self.cuisineScore];
}

- (void)setScore:(NSNumber *)score{
    [self.cuisineScore setStarSpacing:3];
}

- (void)setCuisine:(NSString *)cuisine{
    _cuisine = cuisine;
    self.cuisineLabel.text = cuisine;
    UIImage *bg = [UIImage imageNamed:cuisine];
    if (bg) {
        self.backgroundImage.image = bg;
    }
}
@end
