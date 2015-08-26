//
//  ENFeedbackViewController.m
//  EatNow
//
//  Created by Zitao Xiong on 5/2/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENFeedbackViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AMRatingControl.h"
#import "ENServerManager.h"
#import "ENMainViewController.h"
#import "extobjc.h"
#import "ReactiveCocoa.h"
#import "TMAlertController.h"
#import "TMAlertAction.h"

@interface ENFeedbackViewController ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *didnotGoButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIView *ratingView;
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (nonatomic, assign) UIView *ratingControl;
@property (nonatomic, strong) NSNumber *rating;

@end

@implementation ENFeedbackViewController
@synthesize snap;
+ (instancetype)viewController {
    ENFeedbackViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENFeedbackViewController"];
    return vc;
}

- (BOOL)canSwipe {
    return NO;
}

- (void)didChangedToFrontCard{
    if (self.backgroundImageView.image) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kRestaurantViewImageChangedNotification object:self userInfo:@{@"image": self.backgroundImageView.image}];
    }
}

- (void)setHistory:(NSDictionary *)history{
    _history = history;
    self.restaurant = [[ENRestaurant alloc] initRestaurantWithDictionary:self.history[@"restaurant"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSParameterAssert(self.history);
    NSParameterAssert(self.restaurant);
    [self.backgroundImageView setImageWithURL:[NSURL URLWithString:self.restaurant.imageUrls.firstObject] placeholderImage:nil];
//    NSNumber *like = _history[@"like"];
    [self addRatingOnView:self.ratingView withRating:0];
    
    NSMutableAttributedString *titleAttributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"How was %@", self.restaurant.name]];
    [titleAttributedString addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans-Light" size:28]} range:NSMakeRange(0, 8)];
    [titleAttributedString addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:28]} range:NSMakeRange(8, titleAttributedString.length - 8)];
    self.titleLabel.attributedText = titleAttributedString;
    self.addressLabel.text = _restaurant.streetText;
}

- (void)addRatingOnView:(UIView *)view withRating:(NSInteger)rating{
    UIImage *emptyImageOrNil = [UIImage imageNamed:@"eat-now-feedback-star-grey"];
    UIImage *solidImageOrNil = [UIImage imageNamed:@"eat-now-feedback-star-yellow"];
    AMRatingControl *imagesRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(0, 0) emptyImage:emptyImageOrNil solidImage:solidImageOrNil andMaxRating:5];
    [imagesRatingControl setStarSpacing:3];
    [imagesRatingControl setStarWidthAndHeight:50];
    imagesRatingControl.rating = rating;
    [view addSubview:imagesRatingControl];
    @weakify(self);
    [imagesRatingControl setEditingChangedBlock:^(NSUInteger rating) {
        @strongify(self);
        self.rating = @(rating);
    }];
    self.ratingControl = imagesRatingControl;
}

- (IBAction)onDidnotGoButton:(id)sender {
    [[ENServerManager shared] cancelHistory:self.history[@"_id"] completion:^(NSError *error) {
        if (error) {
            [ENUtil showFailureHUBWithString:@"System error"];
            DDLogError(@"Failed to delete history: %@", error.localizedDescription);
        }
       [self.mainViewController dismissFrontCardWithVelocity:CGPointMake(0, 0) completion:^(NSArray *leftcards) {
           DDLogVerbose(@"History %@ cancelled", _restaurant.name);
//           [ENUtil showText:@"History removed"];
       }];
    }];
}

- (IBAction)onRateButton:(id)sender {
    if (!self.rating) {
        TMAlertController *alertController = [TMAlertController alertControllerWithTitle:nil message:@"Please rate the restaurant." preferredStyle:TMAlartControllerStyleAlert];
        alertController.iconImage = [UIImage imageNamed:@"eat-now-alert-question-mark-icon"];
        [alertController addAction:[TMAlertAction actionWithTitle:@"OK" style:TMAlertActionStyleDefault handler:^(TMAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    [[ENServerManager shared] updateHistory:self.history withRating:[self.rating floatValue] completion:^(NSError *error) {
        if (error) {
            [ENUtil showFailureHUBWithString:@"System error"];
        }
        [self.mainViewController dismissFrontCardWithVelocity:CGPointMake(0, 0) completion:^(NSArray *leftcards) {
            DDLogVerbose(@"Rated %@ for %@", self.rating, self.restaurant.name);
//            [ENUtil showSuccessHUBWithString:@"Preference updated"];
        }];
    }];
}

- (UIView *)shadowView {
    return nil;
}
@end
