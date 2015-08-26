//
//  ENBasePreferenceViewCell.h
//  
//
//  Created by Lei Zhang on 7/12/15.
//
//

#import <UIKit/UIKit.h>

@interface ENBasePreferenceViewCell : UITableViewCell

@property (nonatomic, strong) NSString *cuisine;
@property (nonatomic, strong) NSNumber *score;

@property (weak, nonatomic) IBOutlet UILabel *cuisineLabel;
@property (weak, nonatomic) IBOutlet UIView *rating;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
@end
