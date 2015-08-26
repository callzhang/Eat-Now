//
//  ENBasePreferenceViewController.m
//  
//
//  Created by Lei Zhang on 7/12/15.
//
//

#import "ENBasePreferenceViewController.h"
#import "TMTableViewBuilder.h"
#import "extobjc.h"
#import "ENServerManager.h"
#import "ENBasePreferenceRowItem.h"
#import "UIView+Extend.h"

@interface ENBasePreferenceViewController()
@property (nonatomic, strong) TMTableViewBuilder *builder;
@property (nonatomic, strong) NSDictionary *basePreference;
@end

@implementation ENBasePreferenceViewController
- (void)viewDidLoad{
    
    self.builder = [[TMTableViewBuilder alloc] initWithTableView:self.tableView];
    @weakify(self);
    self.builder.reloadBlock = ^(TMTableViewBuilder *builder) {
        @strongify(self);
        [self setBasePreference:[ENServerManager shared].basePreference];
        [builder removeAllSectionItems];
        TMSectionItem *sectionItem = [TMSectionItem new];
        [builder addSectionItem:sectionItem];
        [self.basePreference enumerateKeysAndObjectsUsingBlock:^(NSString *cuisine, NSNumber *score, BOOL *stop) {
            ENBasePreferenceRowItem *rowItem = [ENBasePreferenceRowItem new];
            rowItem.cuisine = cuisine;
            rowItem.score = score;
            [sectionItem addRowItem:rowItem];
        }];
        
        
        [self.tableView reloadData];
    };
    
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.builder configure];
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
@end
