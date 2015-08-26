//
//  ENHistoryViewController.m
//  EatNow
//
//  Created by Lee on 4/16/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENHistoryViewController.h"
#import "ENServerManager.h"
#import "ENHistoryViewCell.h"
#import "NSDate+MTDates.h"
#import "NSDate+Extension.h"
#import "UIView+Extend.h"
#import "ENRestaurantViewController.h"
#import "ENMainViewController.h"
#import "TMTableViewBuilder.h"
#import "extobjc.h"
#import "ENHistoryHeaderRowItem.h"
#import "ENHistoryRowItem.h"
#import <UITableView-NXEmptyView/UITableView+NXEmptyView.h>

NSString * const kHistoryDetailCardDidShow = @"history_detail_view_did_show";
NSString * const kHistoryTableViewDidShow = @"history_table_view_did_show";

@interface ENHistoryViewController ()
@property (nonatomic, strong) NSDictionary *user;
@property (nonatomic, strong) NSMutableDictionary *history;
@property (nonatomic, strong) NSArray *orderedDates;
@property (nonatomic, strong) NSIndexPath *selectedPath;
@property (nonatomic, strong) TMTableViewBuilder *builder;
@end

@implementation ENHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	if (self.navigationController) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)];
	}
    
    self.builder = [[TMTableViewBuilder alloc] initWithTableView:self.tableView];
    @weakify(self);
    self.builder.reloadBlock = ^(TMTableViewBuilder *builder) {
        @strongify(self);
        [self setDataWithHistory:[ENServerManager shared].history];
        [builder removeAllSectionItems];
        TMSectionItem *sectionItem = [TMSectionItem new];
        [builder addSectionItem:sectionItem];
        for (NSDate *date  in self.orderedDates) {
            ENHistoryHeaderRowItem *rowItem = [ENHistoryHeaderRowItem new];
            rowItem.date = date;
            [sectionItem addRowItem:rowItem];
            
            NSArray *restaurants = self.history[date.mt_endOfCurrentDay];
            for (NSDictionary *dict in restaurants) {
                ENRestaurant *restaurant = dict[@"restaurant"];
                NSNumber *like = dict[@"like"];
                ENHistoryRowItem *hRow = [ENHistoryRowItem new];
                hRow.restaurant = restaurant;
                hRow.rate = like;
                [sectionItem addRowItem:hRow];
                [hRow setDidSelectRowHandler:^(ENHistoryRowItem *rowItem) {
                    @strongify(self);
                    self.selectedPath = rowItem.indexPath;
                    ENHistoryViewCell *cell = (ENHistoryViewCell *)rowItem.cell;
                    CGRect frame = [self.mainView convertRect:cell.background.frame fromView:cell.contentView];
                    [self showRestaurantCard:restaurant fromFrame:frame];
                }];
            }
        }
        [self.tableView reloadData];
    };
    
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.builder configure];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onHistoryUpdated) name:kHistroyUpdated object:nil];
    
}

- (void)viewDidLayoutSubviews {
    if (!self.tableView.nxEV_emptyView) {
        UIView *emptyUIView = [[UIView alloc] initWithFrame:self.view.bounds];
        UIImageView *emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no-history-text-view"]];
        emptyImageView.center = CGPointMake(emptyUIView.frame.size.width / 2, 100);
        [emptyUIView addSubview:emptyImageView];
        self.tableView.nxEV_emptyView = emptyUIView;
    }
}

- (void)onHistoryUpdated {
    [self.builder reloadData];
}

- (void)loadData{
    //data
    self.history = [[ENServerManager shared].history mutableCopy];
    [self.builder reloadData];
    
    [[ENServerManager shared] getUserWithCompletion:^(NSDictionary *user, NSError *error) {
        self.history = [[ENServerManager shared].history mutableCopy];
        [self.builder reloadData];
    }];
}

- (void)setDataWithHistory:(NSArray *)history{
    //generate restaurant
    self.history = [NSMutableDictionary new];

    for (NSDictionary *historyData in history) {
        //json: {restaurant, like, _id, date}
        NSString *dateStr = historyData[@"date"];
        NSDate *date = [NSDate dateFromISO1861:dateStr];
        NSMutableArray *restaurantsDataForThatDay = self.history[[date mt_endOfCurrentDay]];
        if (!restaurantsDataForThatDay) {
            restaurantsDataForThatDay = [NSMutableArray array];
        }
        NSDictionary *data = historyData[@"restaurant"];
        ENRestaurant *restaurant = [[ENRestaurant alloc] initRestaurantWithDictionary:data];
        if (!restaurant) continue;
        [restaurantsDataForThatDay addObject:@{@"restaurant": restaurant, @"like": historyData[@"like"], @"_id": historyData[@"_id" ], @"date": historyData[@"date"]}];
        self.history[[date mt_endOfCurrentDay]] = restaurantsDataForThatDay;
    }

    self.orderedDates = [_history.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSDate *obj1, NSDate *obj2) {
        switch ([obj1 compare:obj2]) {
            case NSOrderedAscending:
                return NSOrderedDescending;
            case NSOrderedDescending:
                return NSOrderedAscending;
            case NSOrderedSame:
                return NSOrderedSame;
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView applyAlphaGradientWithEndPoints:@[@.05, @.95]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.builder reloadData];
}

#pragma mark - Actions
- (IBAction)close:(id)sender{
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)onInfoTapGesture:(UITapGestureRecognizer *)sender {
    [self.restaurantViewController.info removeGestureRecognizer:sender];
    [self closeRestaurantView];
}

- (void)showRestaurantCard:(ENRestaurant *)restaurant fromFrame:(CGRect)frame {
    self.restaurantViewController = [ENRestaurantViewController viewController];
    [self.restaurantViewController switchToStatus:ENRestaurantViewStatusMinimum withFrame:frame animated:NO completion:nil];
    self.restaurantViewController.restaurant = restaurant;
    [self.mainView addSubview:_restaurantViewController.view];
    [self.restaurantViewController didChangedToFrontCard];
    
    
    CGRect toFrame = self.mainViewController.historyContainerView.frame;
    [self.restaurantViewController switchToStatus:ENRestaurantViewStatusHistoryDetail withFrame:toFrame animated:YES completion:nil];
    self.mainViewController.isHistoryDetailShown = YES;
    self.mainViewController.currentMode = ENMainViewControllerModeHistoryDetail;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onInfoTapGesture:)];
    [self.restaurantViewController.info addGestureRecognizer:tap];
}

- (void)closeRestaurantView{
    self.mainViewController.currentMode = ENMainViewControllerModeHistory;
    if (self.restaurantViewController){
        ENHistoryViewCell *cell = (ENHistoryViewCell *)[self.tableView cellForRowAtIndexPath:self.selectedPath];
        CGRect frame = [cell.contentView convertRect:cell.background.frame toView:self.mainView];
        [self.restaurantViewController switchToStatus:ENRestaurantViewStatusMinimum withFrame:frame animated:YES completion:^{
        }];
        [UIView animateWithDuration:0.2 delay:0.1 options:0 animations:^{
            self.restaurantViewController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self.restaurantViewController.view removeFromSuperview];
            self.restaurantViewController = nil;
        }];
        
        ENMainViewController *mainVC = (ENMainViewController *)self.parentViewController;
        mainVC.isHistoryDetailShown = NO;
    }
}
@end
