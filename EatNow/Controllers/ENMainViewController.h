//
// ChoosePersonViewController.h
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

#import <UIKit/UIKit.h>
#import "ENRestaurantViewController.h"



typedef NS_ENUM(NSUInteger, ENMainViewControllerMode) {
    ENMainViewControllerModeMain,
    ENMainViewControllerModeDetail,
    ENMainViewControllerModeHistory,
    ENMainViewControllerModeHistoryDetail,
    ENMainViewControllerModeMap,
};

@interface ENMainViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *cardView;
@property (weak, nonatomic) IBOutlet UIView *cardContainer;
@property (weak, nonatomic) IBOutlet UILabel *loadingInfo;
//frame
//@property (nonatomic, readonly) ENRestaurantViewController *frontCardView;
@property (nonatomic, strong) NSMutableArray *cards;
//states
@property (nonatomic, assign) BOOL isSearchingFromServer;
@property (nonatomic, assign) BOOL isShowingCards;
@property (nonatomic, assign) BOOL isHistoryDetailShown;

@property (weak, nonatomic) IBOutlet UIView *historyContainerView;
@property (nonatomic, assign) BOOL isDismissingCard;
@property (nonatomic, assign) BOOL needShowRestaurant;
@property (nonatomic, assign) ENMainViewControllerMode currentMode;

//tweak
@property (nonatomic, assign) BOOL showFeedback;
@property (nonatomic, assign) BOOL showScore;

- (void)dismissFrontCardWithVelocity:(CGPoint)velocity completion:(void (^)(NSArray *leftcards))completion;
@end
