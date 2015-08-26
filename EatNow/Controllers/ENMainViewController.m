//
// ChoosePersonViewController.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ENMainViewController.h"
#import "ENRestaurant.h"
#import "ENServerManager.h"
#import "FBKVOController.h"
#import "ENProfileViewController.h"
#import "ENLocationManager.h"
#import "UIAlertView+BlocksKit.h"
#import "UIActionSheet+BlocksKit.h"
#import "extobjc.h"
#import "NSTimer+BlocksKit.h"
#import "ENHistoryViewController.h"
#import "ENUtil.h"
#import "UIView+Extend.h"
#import "ATConnect.h"
#import "ENRatingView.h"
#import "ENProfileViewController.h"
#import "ENFeedbackViewController.h"
#import "NSDate+Extension.h"
#import "EnShapeView.h"
#import "NSError+EatNow.h"
#import "BlocksKit.h"
#import "GNMapOpenerItem.h"
#import "GNMapOpener.h"
#import "Mixpanel.h"
#import "UIViewController+blur.h"
#import "ENPreferenceTagsViewController.h"
#import "WeixinActivity.h"

@interface ENMainViewController ()
//data
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) NSMutableArray *historyToReview;
@property (nonatomic, strong) ENLocationManager *locationManager;
@property (nonatomic, strong) ENServerManager *serverManager;
//UIDynamics
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachment;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UIDynamicItemBehavior *dynamicItem;
//gesture
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;
//UI
@property (weak, nonatomic) IBOutlet UIImageView *background;
@property (nonatomic, strong) ENHistoryViewController *historyViewController;
//autolayout
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailCardTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailCardLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyChildViewControllerTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *historyChildViewControllerLeadingConstraint;
@property (weak, nonatomic) IBOutlet UILabel *noRestaurantsLabel;
//control
@property (weak, nonatomic) IBOutlet UIImageView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *mainViewButton;
@property (weak, nonatomic) IBOutlet UIButton *histodyDetailToHistoryButton;
@property (weak, nonatomic) IBOutlet UIButton *consoleButton;
@property (weak, nonatomic) IBOutlet UIButton *closeMapButton;
@property (weak, nonatomic) IBOutlet UIButton *openInMapsButton;
//@property (nonatomic, strong) NSTimer *showRestaurantCardTimer;
@property (nonatomic, weak) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) EnShapeView *dotFrameView;
@property (nonatomic, assign) BOOL showLocationRequestTime;

//animation
@property (nonatomic, assign) float cardShowInterval;
@property (nonatomic, assign) NSUInteger maxCardsToAnimate;
@property (nonatomic, assign) NSUInteger maxCards;
@property (nonatomic, assign) float cardShowIntervalDiminishingDelta;
@property (nonatomic, assign) float snapDamping;
@property (nonatomic, assign) float backgroundImageDelay;
@property (nonatomic, assign) float panGustureSnapBackDistance;
@end


@implementation ENMainViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Accsessor
- (ENRestaurantViewController *)firstRestaurantViewController{
    return self.cards.firstObject;
}

- (void)setRestaurants:(NSMutableArray *)restaurants{
    if (restaurants.count > _maxCards) {
        DDLogInfo(@"Trunked restaurant list from %@ to %lu", @(restaurants.count), (unsigned long)_maxCards);
        restaurants = [restaurants objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,_maxCards)]].mutableCopy;
	}
	DDLogVerbose(@"%@", [restaurants valueForKey:@"name"]);
    _restaurants = restaurants;
}

- (void)setCurrentMode:(ENMainViewControllerMode)currentMode {
    _currentMode = currentMode;
    
    switch (_currentMode) {
        case ENMainViewControllerModeMain: {
            [self showControllers:@[self.historyButton, self.reloadButton, self.shareButton, self.consoleButton]];
            break;
        }
        case ENMainViewControllerModeDetail: {
            [self showControllers:@[self.closeButton, self.consoleButton]];
            break;
        }
        case ENMainViewControllerModeHistory: {
            [self showControllers:@[self.mainViewButton, self.consoleButton]];
            break;
        }
        case ENMainViewControllerModeHistoryDetail :{
            [self showControllers:@[self.histodyDetailToHistoryButton, self.consoleButton]];
            break;
        }
        case ENMainViewControllerModeMap: {
            [self showControllers:@[self.closeMapButton, self.openInMapsButton]];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)showControllers:(NSArray *)controls animated:(BOOL)animated {
    [self showViews:controls inAllViews:@[self.historyButton, self.reloadButton, self.shareButton, self.closeButton, self.mainViewButton, self.histodyDetailToHistoryButton, self.closeMapButton, self.openInMapsButton, self.consoleButton] animated:animated];
}

- (void)showControllers:(NSArray *)controls {
    [self showControllers:controls animated:YES];
}

- (void)showViews:(NSArray *)showViews inAllViews:(NSArray *)allViews animated:(BOOL)animated {
    NSArray *hideViews = [allViews bk_reject:^BOOL(id obj) {
        return [showViews containsObject:obj];
    }];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            [showViews bk_each:^(UIView *obj) {
                obj.alpha = 1.0f;
            }];
            
            [hideViews bk_each:^(UIView *obj) {
                obj.alpha = 0.0f;
            }];
        }];
    }
    else {
        [showViews bk_each:^(UIView *obj) {
            obj.alpha = 1.0f;
        }];
        
        [hideViews bk_each:^(UIView *obj) {
            obj.alpha = 0.0f;
        }];
    }
}

#pragma mark - UIViewController Lifecycle
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupDotFrameView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.KVOController observe:self keyPath:@keypath(self, showFeedback) options:NSKeyValueObservingOptionNew block:^(id observer, ENMainViewController *mainVC, NSDictionary *change) {
        if (mainVC.showFeedback) {
            self.consoleButton.hidden = NO;
        }else{
            self.consoleButton.hidden = YES;
        }
    }];
}

- (void)viewDidLoad {
    //tweak
    FBTweakBind(self, showScore, @"Algorithm", @"Inspect", @"Show score", NO);
    FBTweakBind(self, showFeedback, @"Main view", @"Feedback", @"Show feedback", YES);
    FBTweakBind(self, showLocationRequestTime, @"Location", @"request", @"Show request time", NO);
    FBTweakBind(self, maxCards, @"Animation", @"Card animation", @"Max cards", 12);
    FBTweakBind(self, maxCardsToAnimate, @"Animation", @"Card animation", @"Cards to animate", 6);
    FBTweakBind(self, cardShowInterval, @"Animation", @"Card animation", @"Cards show interval", 0.2);
    FBTweakBind(self, cardShowIntervalDiminishingDelta, @"Animation", @"Card animation", @"Diminishing delta", 0.03);
    FBTweakBind(self, backgroundImageDelay, @"Animation", @"Backdound blur", @"Backgound delay", 3.0);
    FBTweakBind(self, panGustureSnapBackDistance, @"Animation", @"Snap", @"Snap back distance", 50);
    FBTweakBind(self, snapDamping, @"Animation", @"Snap", @"Snap damping", 0.8);
    
    [[Mixpanel sharedInstance] timeEvent:@"Card shown"];
    [super viewDidLoad];
    self.locationManager = [ENLocationManager shared];
    self.serverManager = [ENServerManager shared];
    self.cards = [NSMutableArray array];
    [self showControllers:@[self.historyButton, self.reloadButton, self.shareButton] animated:NO]; //disable animation
    self.currentMode = ENMainViewControllerModeMain;

    [self setupNoRestaurantStatus];
    
    //fetch user first
    [[ENServerManager shared] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        if (user) {
            NSParameterAssert([ENServerManager shared].userRating);
            NSParameterAssert([ENServerManager shared].history);
            DDLogVerbose(@"Got user history and rating data");
        }
    }];
    
    //Dynamics
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.cardContainer];
    self.gravity = [[UIGravityBehavior alloc] init];
    self.gravity.gravityDirection = CGVectorMake(0, 10);
    [self.animator addBehavior:_gravity];
    self.dynamicItem = [[UIDynamicItemBehavior alloc] init];
    self.dynamicItem.density = 1.0;
    [self.animator addBehavior:_dynamicItem];

    
    [self.KVOController observe:self keyPaths:@[@keypath(self.needShowRestaurant), @keypath(self.isSearchingFromServer), @keypath(self.isDismissingCard), @keypath(self.isShowingCards)] options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        if (!self.isSearchingFromServer && !self.isShowingCards && !self.isDismissingCard) {
            self.reloadButton.enabled = YES;
            self.shareButton.enabled = YES;
            self.loadingIndicator.alpha = 0;
            //DDLogInfo(@"show loding indicator :%@ %@ %@", @(self.isSearchingFromServer), @(self.isShowingCards), @(self.isDismissingCard));
        }
        else {
            self.reloadButton.enabled = NO;
            self.shareButton.enabled = NO;
            self.loadingIndicator.alpha = 1;
            //DDLogInfo(@"hide loding indicator :%@ %@ %@", @(self.isSearchingFromServer), @(self.isShowingCards), @(self.isDismissingCard));
        }
        
        if (self.needShowRestaurant && !self.isSearchingFromServer && !self.isDismissingCard && !self.isShowingCards) {
            self.needShowRestaurant = NO;
            [self showAllRestaurantCards];
        }
    }];

    //history to review
    [[NSNotificationCenter defaultCenter] addObserverForName:kHistroyUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {

        self.historyToReview = [NSMutableArray array];

        for (NSDictionary *historyData in [ENServerManager shared].history) {

            NSString *dateStr = historyData[@"date"];
            NSDate *date = [NSDate dateFromISO1861:dateStr];
            BOOL reviewTimePassed = [[NSDate date] timeIntervalSinceDate:date] > kMaxSelectedRestaurantRetainTime;
#ifdef DEBUG
            //review immediately in debug
            reviewTimePassed = YES;
#endif
            BOOL needReview = [historyData[@"reviewed"] boolValue] == NO;

            if (reviewTimePassed && needReview) {
                [self.historyToReview addObject:historyData];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kBasePreferenceUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
        //refresh
        [self onReloadButton:nil];
    }];
	
    //load restaurants from server
    [self searchNewRestaurantsWithCompletion:nil];
    
    self.cardView.backgroundColor = [UIColor clearColor];
    self.cardContainer.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
	
	//loading gif
	NSArray *images = @[[UIImage imageNamed:@"eat-now-loading-indicator-1"],
						[UIImage imageNamed:@"eat-now-loading-indicator-2"],
						[UIImage imageNamed:@"eat-now-loading-indicator-3"],
						[UIImage imageNamed:@"eat-now-loading-indicator-4"],
						[UIImage imageNamed:@"eat-now-loading-indicator-5"],
						[UIImage imageNamed:@"eat-now-loading-indicator-6"]];
	self.loadingIndicator.animationImages = images;
	self.loadingIndicator.animationDuration = 1.2;
    [self.loadingIndicator startAnimating];
	
    if (!self.visualEffectView) {
        //background
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *bluredEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        [bluredEffectView setFrame:self.view.frame];
        [self.view insertSubview:bluredEffectView aboveSubview:self.background];
        self.visualEffectView = bluredEffectView;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onRestauranntViewImageDidChangeNotification:) name:kRestaurantViewImageChangedNotification object:nil];
    
    //hide history view
    [self toggleHistoryView];
    
    [self setupDotFrameView];
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (void)onRestauranntViewImageDidChangeNotification:(NSNotification *)notification {
    if (notification.object == self.firstRestaurantViewController) {
        [self setBackgroundImage:notification.userInfo[@"image"]];
    }
}

#pragma mark - IBActioning
- (IBAction)onSettingButton:(id)sender {
    
    ENPreferenceTagsViewController *vc = [[UIStoryboard storyboardWithName:@"main" bundle:nil] instantiateViewControllerWithIdentifier:@"ENPreferenceTagsViewController"];
    //UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentWithBlur:vc withCompletion:nil];    
}

- (IBAction)onHistoryButton:(id)sender {
    self.currentMode = ENMainViewControllerModeHistory;
    
    [self toggleHistoryView];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (IBAction)onCloseButton:(id)sender {
    [self toggleCardDetails];
}

- (IBAction)onCloseMapButton:(id)sender {
    [[Mixpanel sharedInstance] track:@"Close map"];
    [[self firstRestaurantViewController] closeMap];
    self.currentMode = ENMainViewControllerModeDetail;
}

- (IBAction)onReloadButton:(id)sender {
    [[Mixpanel sharedInstance] track:@"reload" properties:@{@"index": @(_maxCards - _cards.count +1),
                                                           @"session": [ENServerManager shared].session}];
    [self hideNoRestaurantStatus];
    
    if (self.isShowingCards) {
        DDLogInfo(@"showing cards, ignore reload button");
        return;
    }
    NSLog(@"reload button clicked");
    NSParameterAssert(!self.isSearchingFromServer);
    NSParameterAssert(!self.isShowingCards);
    NSParameterAssert(!self.isDismissingCard);
    self.isDismissingCard = YES;
    
    self.restaurants = nil;
    
    if (self.cards.count == 0) {
        self.isDismissingCard = NO;
    }
    
    NSUInteger cardViewCount = self.cards.count;
    
    for (NSUInteger i = _maxCardsToAnimate; i < cardViewCount ; i++) {
        ENRestaurantViewController *card = self.cards[i];
        [card.view removeFromSuperview];
        [card removeFromParentViewController];
    }
    
    if (cardViewCount > _maxCardsToAnimate) {
        [self.cards removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(_maxCardsToAnimate, cardViewCount - _maxCardsToAnimate)]];
    }

    
    NSUInteger dismissCardViewCount = self.cards.count;
    //dismissing with animation
    for (int i = 0; i < dismissCardViewCount; i++) {
        float delay = i * _cardShowInterval - (i*i-i)/2 * _cardShowIntervalDiminishingDelta;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGPoint v = CGPointMake(50.0f - arc4random_uniform(100), 0);
            [self dismissFrontCardWithVelocity:v completion:nil];
            
            if (i == dismissCardViewCount - 1) {
                self.isDismissingCard = NO;
            }
        });
    }

    //search for new
    [self searchNewRestaurantsWithCompletion:nil];

}

- (IBAction)onHistoryToMainViewButton:(id)sender {
    self.currentMode = ENMainViewControllerModeMain;
    [self toggleHistoryView];
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {

    }];
}

- (IBAction)onHistoryDetailToHistoryButton:(id)sender {
    self.currentMode = ENMainViewControllerModeHistoryDetail;
    
    [self.historyViewController closeRestaurantView];
}

- (IBAction)onOpenInMapsButton:(id)sender {
    CLLocation *location = [self firstRestaurantViewController].restaurant.location;
    GNMapOpenerItem *item = [[GNMapOpenerItem alloc] initWithLocation:location];
    item.name = [self firstRestaurantViewController].restaurant.name;
    item.directionsType = GNMapOpenerDirectionsTypeWalk;
    [[GNMapOpener sharedInstance] openItem:item presetingViewController:self];
}

- (IBAction)onShareButton:(id)sender
{
    ENRestaurantViewController *restaurantVC = [self firstRestaurantViewController];
    
    if (!restaurantVC) {
        DDLogWarn(@"No restaurant view controller for sharing");
        return;
    }
    
    NSString *shareDesc = @"I found a great restaurant...";
    //TODO: Get sharing image from restaurant view controller which would have a round corner.
    UIImage *cardImage = [restaurantVC.view toImage];
    
    NSArray *activities = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
    
    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[shareDesc, cardImage] applicationActivities:activities];
    
    shareVC.excludedActivityTypes = @[UIActivityTypeMessage,
                                      UIActivityTypePrint,
                                      UIActivityTypeCopyToPasteboard,
                                      UIActivityTypeAssignToContact,
                                      UIActivityTypeAddToReadingList,
                                      UIActivityTypeAirDrop,
                                      UIActivityTypePrint,
                                      UIActivityTypeSaveToCameraRoll];
    
    [self presentViewController:shareVC animated:YES completion:nil];

}

#pragma mark - Main methods

- (void)searchNewRestaurantsWithCompletion:(void (^)(NSArray *response, NSError *error))block {
    
    self.isSearchingFromServer = YES;
    NSDate *start = [NSDate date];
    @weakify(self);
    self.loadingInfo.hidden = YES;
    [self.locationManager getLocationWithCompletion:^(CLLocation *location, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        @strongify(self);
        if (self.showLocationRequestTime) {
            NSString *str = [NSString stringWithFormat:@"It took %.0fs to get location", [[NSDate date] timeIntervalSinceDate:start]];
            [ENUtil showText:str];
        }
        if (location) {
            [self.serverManager searchRestaurantsAtLocation:location WithCompletion:^(BOOL success, NSError *error, NSArray *response) {
                @strongify(self);
                self.isSearchingFromServer = NO;
                if (success) {
                    self.restaurants = response.mutableCopy;
                    if (self.restaurants.count == 0) {
                        [self showNoRestaurantStatus];
                    }
                    self.needShowRestaurant = YES;//need to place after the _restaurants is assigned
                }else {
                    self.needShowRestaurant = NO;
                    [self handleError:error];
                }
                
                if(block) block(response, error);
            }];
        }
        else {
            self.isSearchingFromServer = NO;
            NSError *error = [NSError errorWithDomain:kEatNowErrorDomain code:EatNowErrorTypeLocaltionNotAvailable userInfo:nil];
            [self handleError:error];
            if(block) block(nil, error);
        }
    } ];
}

- (void)showAllRestaurantCards{
    NSParameterAssert(!self.isSearchingFromServer);
    if (self.cards.count > 0) {
        DDLogWarn(@"=== Already have cards, skip showing restaurant");
        return;
    }
    
    if (self.restaurants.count == 0) {
        DDLogWarn(@"No restaurant to show, skip showing restaurants");
        return;
    }
    
    self.loadingInfo.text = @"";
    self.isShowingCards = YES;
    
    [[Mixpanel sharedInstance] track:@"Card shown" properties:@{@"session": [ENServerManager shared].session}];
    // Display cards animated
    NSUInteger restaurantCount = _restaurants.count;
    NSUInteger feedbackCount = self.historyToReview.count;
    NSUInteger totalCardCount = restaurantCount + feedbackCount;
    NSMutableArray *cards = [NSMutableArray array];
    NSUInteger historyToReviewCount = self.historyToReview.count;
    
    for (NSInteger i = 1; i <= totalCardCount; i++) {
        //insert card
        UIViewController<ENCardViewControllerProtocol> *card;
        if (historyToReviewCount > 0) {
            historyToReviewCount--;
            ENFeedbackViewController *feedbackViewController = [self popFeedbackViewWithFrame:[self initialCardFrame]];
            card = feedbackViewController;
        }else{
            ENRestaurantViewController *restaurantViewController = [self popResuturantViewWithFrame:[self initialCardFrame]];
            card = restaurantViewController;
        }
        card.view.hidden = YES;
        [cards addObject:card];

        if (i==1) {
			//DDLogVerbose(@"Poping %@th card: %@", @(i), restaurantViewController.restaurant.name);
            [self addChildViewController:card];
            [self.cardContainer addSubview:card.view];
            [card.view addGestureRecognizer:self.panGesture];
            if ([card isKindOfClass:[ENRestaurantViewController class]]) [[(ENRestaurantViewController *)card info] addGestureRecognizer:self.tapGesture];
            [card didChangedToFrontCard];
        }
        else{
			//DDLogVerbose(@"Poping %@th card: %@", @(i), restaurantViewController.restaurant.name);
            //insert behind previous card
            ENRestaurantViewController *previousCard = self.cards[i-2];
            NSParameterAssert(previousCard.view.superview);
            [self.cardContainer insertSubview:card.view belowSubview:previousCard.view];
        }
        
        //animate
        if (i <= _maxCardsToAnimate){
            //animate
            float j = (_maxCardsToAnimate - i + 1);
            float delay = j * _cardShowInterval - (j*j-j)/2 * _cardShowIntervalDiminishingDelta;
            DDLogVerbose(@"Delay %f sec for %ldth card", delay, (long)i);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                card.view.hidden = NO;
                [self showCardToCenter:card];
                DDLogVerbose(@"Animating %ldth card to center", (long)i);
            });
        }
        else {
            float delay = _maxCardsToAnimate * _cardShowInterval;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                card.view.frame = [self cardViewFrame];
                card.view.hidden = NO;
                DDLogVerbose(@"Showing %ldth card", (long)i);
            });
        }
        
        //finish
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((_maxCardsToAnimate * _cardShowInterval + 1) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.isShowingCards = NO;
        });
    }
}

- (void)dismissFrontCardWithVelocity:(CGPoint)velocity completion:(void (^)(NSArray *leftcards))completion {
    if (self.firstRestaurantViewController) {
        //mixpanel
        [[Mixpanel sharedInstance].people increment:@"dismiss" by:@1];
        [[Mixpanel sharedInstance] track:@"Dismiss" properties:@{@"index": @(_maxCards - _cards.count + 1),
                                                                 @"session": [ENServerManager shared].session}];
        
        ENRestaurantViewController *card = self.firstRestaurantViewController;
        //DDLogInfo(@"Dismiss card %@", frontCard.restaurant.name);
        //add dynamics
        [self.animator removeBehavior:card.snap];
        [self.gravity addItem:card.view];
        [self.dynamicItem addItem:card.view];
        //add initial velocity
        if (velocity.x) {
            [self.dynamicItem addLinearVelocity:velocity forItem:card.view];
        }
        //add rotation
        float initialAngle = (arc4random_uniform(100) - 50.0f)/100.0f * M_PI / 2;
        [self.dynamicItem addAngularVelocity:initialAngle forItem:card.view];
        
        //remove front card from cards
        [self.cards removeObjectAtIndex:0];
        
        //add pan gesture to next
        [card.view removeGestureRecognizer:self.panGesture];
        if ([card isKindOfClass:[ENRestaurantViewController class]]) {
            [card.info removeGestureRecognizer:self.tapGesture];
        }
        [self.firstRestaurantViewController.view addGestureRecognizer:self.panGesture];
        if ([self.firstRestaurantViewController isKindOfClass:[ENRestaurantViewController class]]) {
            [self.firstRestaurantViewController.info addGestureRecognizer:self.tapGesture];
        }
        
        //notify next card
        [self.firstRestaurantViewController didChangedToFrontCard];
        
        //delay
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                card.view.alpha = 0;
            } completion:^(BOOL finished) {
                [_gravity removeItem:card.view];
                [_dynamicItem removeItem:card.view];
                [card.view removeFromSuperview];
                if(completion) completion(self.cards);
            }];
        });
    }
}

- (void)toggleCardDetails{
    [_animator removeBehavior:self.firstRestaurantViewController.snap];
    //open first card
    //TODO? might use current mode for switcing
    if (self.firstRestaurantViewController.status == ENRestaurantViewStatusCard) {
        [[Mixpanel sharedInstance] track:@"Open card detail" properties:@{@"index": @(_maxCards - _cards.count + 1),
                                                                          @"session": [ENServerManager shared].session}];
        [self.firstRestaurantViewController switchToStatus:ENRestaurantViewStatusDetail withFrame:self.cardContainer.bounds animated:YES completion:nil];
        [self.firstRestaurantViewController.view removeGestureRecognizer:self.panGesture];
        
        self.currentMode = ENMainViewControllerModeDetail;
    }
    //close first card
    else {
        [[Mixpanel sharedInstance] track:@"Close card detail" properties:@{@"index": @(_maxCards - _cards.count + 1),
                                                                           @"session": [ENServerManager shared].session}];
        [self.firstRestaurantViewController switchToStatus:ENRestaurantViewStatusCard withFrame:self.cardViewFrame animated:YES completion:nil];
        [self.firstRestaurantViewController.view addGestureRecognizer:self.panGesture];
        
        self.currentMode = ENMainViewControllerModeMain;
    }
}

- (void)toggleHistoryView {
    if (self.currentMode == ENMainViewControllerModeHistory) {
        //show
        self.historyChildViewControllerLeadingConstraint.constant = 0;
        self.historyChildViewControllerTrailingConstraint.constant = 0;
        self.detailCardLeadingConstraint.constant = self.view.frame.size.width;
        self.detailCardTrailingConstraint.constant = -self.view.frame.size.width;
        [self.historyViewController loadData];
        self.historyViewController.mainView = self.view;
    }
    else {
        //close
        self.historyChildViewControllerLeadingConstraint.constant = -self.view.frame.size.width;
        self.historyChildViewControllerTrailingConstraint.constant = self.view.frame.size.width;
        self.detailCardLeadingConstraint.constant = 0;
        self.detailCardTrailingConstraint.constant = 0;
        self.historyViewController.mainView = nil;
        if (self.historyViewController.restaurantViewController) {
            [self.historyViewController closeRestaurantView];
        }
    }
    
    [super updateViewConstraints];
}

#pragma mark - Guesture actions
- (IBAction)tapHandler:(UITapGestureRecognizer *)gesture {
    [self toggleCardDetails];
}

- (IBAction)panHandler:(UIPanGestureRecognizer *)gesture {
    CGPoint locInView = [gesture locationInView:self.animator.referenceView];
    CGPoint locInCard = [gesture locationInView:self.firstRestaurantViewController.view];
    
    ENRestaurantViewController *card= self.firstRestaurantViewController;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //remove snap
        [self.animator removeBehavior:self.firstRestaurantViewController.snap];
        //attachment behavior
        [_animator removeBehavior:_attachment];
        UIOffset offset = UIOffsetMake(locInCard.x - card.view.bounds.size.width/2, locInCard.y - card.view.bounds.size.height/2);
        _attachment = [[UIAttachmentBehavior alloc] initWithItem:card.view offsetFromCenter:offset attachedToAnchor:locInView];
        [_animator addBehavior:_attachment];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        _attachment.anchorPoint = locInView;
    }
    else if (gesture.state == UIGestureRecognizerStateEnded){
        [_animator removeBehavior:_attachment];
        CGPoint translation = [gesture translationInView:self.view];
        BOOL canSwipe = card.canSwipe;
        BOOL panDistanceLargeEnough = sqrtf(pow(translation.x, 2) + pow(translation.y, 2)) > _panGustureSnapBackDistance;
        if (canSwipe && panDistanceLargeEnough) {
            //add dynamic item behavior
            CGPoint velocity = [gesture velocityInView:self.view];
            [self dismissFrontCardWithVelocity:velocity completion:^(NSArray *leftcards) {
                if (leftcards.count == 0) {
                    //show loading info
                    self.loadingInfo.text = @"\n\nSeems you didn’t like any of the recommendations. Press Refresh and try your luck again?";
                    self.loadingInfo.hidden = NO;
                }
            }];
        }
        else {
            [[Mixpanel sharedInstance] track:@"Undecisive" properties:@{@"index": @(_maxCards - _cards.count + 1),
                                                                        @"session": [ENServerManager shared].session}];
            [self snapCardToCenter:card];
        }
    }
}

// This is called when a user didn't fully swiped
- (void)snapCardToCenter:(UIViewController<ENCardViewControllerProtocol> *)card {
    NSParameterAssert(card);
    if (card.snap) {
        //skip if snap is already in place
        return;
        //[self.animator removeBehavior:card.snap];
    }
    if (!card.view.superview) {
        //skip if not in view
        return;
    }
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:card.view snapToPoint:self.cardView.center];
    
    snap.damping = _snapDamping;
    [self.animator addBehavior:snap];
    card.snap = snap;
}

//发卡效果
- (void)showCardToCenter:(UIViewController<ENCardViewControllerProtocol> *)card{
    NSParameterAssert(card);
    //initial ramdom
    //float initialAngle = (arc4random_uniform(100) - 50.0f)/100.0f * M_PI / 10;
    //rotate
    //card.view.transform = CGAffineTransformMakeRotation(initialAngle);
    //move to center
    [UIView animateWithDuration:0.7 delay:0 usingSpringWithDamping:_snapDamping initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = card.view.frame;
        frame.origin = self.cardView.frame.origin;
        card.view.frame = frame;
        card.view.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
    }];
    
}

#pragma mark - Internal Methods
//data methods, should not add view related codes
//Pop start from the first one
- (ENRestaurantViewController *)popResuturantViewWithFrame:(CGRect)frame {
    if (self.restaurants.count == 0) {
        DDLogWarn(@"No restaurant to pop");
        return nil;
    }
    ENRestaurantViewController* card = [ENRestaurantViewController viewController];
    card.status = ENRestaurantViewStatusCard;
    card.mainVC = self;
    card.view.frame = frame;
    card.restaurant = self.restaurants.firstObject;
    [card updateLayout];
	[self.restaurants removeObjectAtIndex:0];
    [self.cards addObject:card];
    
    return card;
}

- (ENFeedbackViewController *)popFeedbackViewWithFrame:(CGRect)frame {
    if (self.historyToReview.count == 0) {
        DDLogWarn(@"No feedback to pop");
        return nil;
    }
    NSDictionary *historyData = self.historyToReview.firstObject;
    ENFeedbackViewController *card = [ENFeedbackViewController viewController];
    card.history = historyData;
    card.mainViewController = self;
    card.view.frame = frame;
    [self.historyToReview removeObjectAtIndex:0];
    [self.cards addObject:card];

    return card;
}

- (void)setBackgroundImage:(UIImage *)image{
    static NSTimer *BGTimer;
    [BGTimer invalidate];
    BGTimer = [NSTimer bk_scheduledTimerWithTimeInterval:_backgroundImageDelay block:^(NSTimer *timer) {
        //duplicate view
        UIView *imageViewCopy = [self.background snapshotViewAfterScreenUpdates:NO];
        //apply filter
        CIImage *input = [CIImage imageWithCGImage:image.CGImage];
        CIFilter *filter = [CIFilter filterWithName:@"CIColorControls"
                                     withInputParameters:@{kCIInputImageKey: input,
                                                           @"inputSaturation": @0.3,
                                                           @"inputBrightness": @0,
                                                           @"inputContrast": @1}];
        CIImage *output = [filter valueForKey:kCIOutputImageKey];
        UIImage *dampen = [UIImage imageWithCIImage:output];
        self.background.image = dampen;
        self.background.contentMode = UIViewContentModeScaleAspectFill;
        [self.view insertSubview:imageViewCopy aboveSubview:self.background];
        [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            imageViewCopy.alpha = 0;
        } completion:^(BOOL finished) {
            [imageViewCopy removeFromSuperview];
        }];
    } repeats:NO];
}

- (void)handleError:(NSError *)error {
    if (!error) {
        return;
    }
    if ([error.domain isEqualToString:kEatNowErrorDomain] && error.code == EatNowErrorTypeLocaltionNotAvailable) {
        //location not available
        
        self.loadingInfo.text = @"Sorry, I cannot determine your location. \n\nPlease try again later.";
        self.loadingInfo.hidden = NO;
    } else {
        //handle server error
        self.loadingInfo.text = @"Sorry, I cannot connect to server. \n\nPlease try again later.";
        self.loadingInfo.hidden = NO;
        
    }
}

#pragma mark - Card frame
- (CGRect)initialCardFrame{
    CGRect frame = self.cardView.frame;
    frame.origin.x = arc4random_uniform(400) - 100.0f;
    frame.origin.y -= [UIScreen mainScreen].bounds.size.height/2 + frame.size.height;
    return frame;
}

- (CGRect)cardViewFrame {
    CGRect frame = self.cardView.frame;
    return frame;
}

- (CGRect)detailViewFrame{
    CGRect frame = self.cardContainer.frame;
    return frame;
}

#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"embedHistorySegue"]) {
        self.historyViewController = segue.destinationViewController;
        self.historyViewController.mainViewController = self;
    }
}

#pragma mark -
- (void)showNoRestaurantStatus {
    self.noRestaurantsLabel.hidden = NO;
}

- (void)hideNoRestaurantStatus {
    self.noRestaurantsLabel.hidden = YES;
}

- (void)setupNoRestaurantStatus {
    NSMutableAttributedString *text = [[[NSAttributedString alloc] initWithString:@"Too bad. Eat Now didn’t find any restaurant nearby. :(" attributes:@{}] mutableCopy];
    [text addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"OpenSans" size:28]} range:NSMakeRange(0, 6)];
    [text addAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"OpenSans-Light" size:20]} range:NSMakeRange(6, text.length - 6)];
    self.noRestaurantsLabel.attributedText = text;
}

#pragma mark - 
- (void)setupDotFrameView {
    CGRect cardFrame = self.cardView.bounds;
    CGFloat shrink = 2;
    cardFrame = CGRectMake(cardFrame.origin.x + shrink, cardFrame.origin.y + shrink, cardFrame.size.width - shrink*2, cardFrame.size.height - shrink*2);
    
    if (!self.dotFrameView) {
        CGFloat onePixel = 1.0 / [UIScreen mainScreen].scale;
        
        self.dotFrameView = [[EnShapeView alloc] init];
        
        self.dotFrameView.shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:cardFrame cornerRadius:16].CGPath;
        self.dotFrameView.shapeLayer.lineWidth = 2 * onePixel;
        self.dotFrameView.shapeLayer.lineCap = kCALineCapRound; //kCALineCapButt;
        self.dotFrameView.shapeLayer.lineDashPattern = @[@(1 * onePixel), @(10 * onePixel)];
        self.dotFrameView.shapeLayer.fillColor = nil;
        self.dotFrameView.shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        [self.cardView insertSubview:self.dotFrameView atIndex:2];
    }
    else {
        self.dotFrameView.shapeLayer.path = [UIBezierPath bezierPathWithRoundedRect:cardFrame cornerRadius:16].CGPath;
    }
}
@end
