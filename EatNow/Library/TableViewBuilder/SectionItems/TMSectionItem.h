//
//  TMSectionItem.h
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMRowItem.h"
@protocol TMSectionItemProtocol <NSObject>
//---------------- MAP to UITableViewDelegate ---------------
@optional
- (void)willDisplayHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)willDisplayFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)didEndDisplayingHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)didEndDisplayingFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0);

- (CGFloat)heightForHeader;
- (CGFloat)heightForFooter;

- (CGFloat)estimatedHeightForHeader NS_AVAILABLE_IOS(7_0);
- (CGFloat)estimatedHeightForFooter NS_AVAILABLE_IOS(7_0);
- (UIView *)viewForHeader;   // custom view for header. will be adjusted to default or specified header height
- (UIView *)viewForFooter;   // custom view for footer. will be adjusted to default or specified footer height

//---------------- MAP to UITableViewDataSource ---------------
@required
- (NSInteger)numberOfRows;
@optional
- (NSString *)titleForHeader;    // fixed font style. use custom view (UILabel) if you want something different
- (NSString *)titleForFooter;
@end

@class TMTableViewBuilder;

@interface TMSectionItem : NSObject <TMSectionItemProtocol>
@property (nonatomic, readonly, weak) TMTableViewBuilder *tableViewBuilder;
@property (nonatomic, readonly) NSInteger section;
- (void)addRowItem:(TMRowItem *)rowItem;
- (TMRowItem *)rowItemAtIndex:(NSUInteger)index;
- (void)removeRowItemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfRowItem:(TMRowItem *)rowItem;

- (void)removeFromTableView;
- (void)removeFromTableViewAnimated:(BOOL)animated;
#pragma mark - Section Property
- (NSInteger)numberOfRows;
@property (nonatomic, strong) NSString *titleForHeader;
@property (nonatomic, strong) NSString *titleForFooter;
//in order for heightForHeader to work, estimatedHeightForHeader must be set
@property (nonatomic, assign) CGFloat heightForHeader;
//in order for heightForFooter to work, estimatedHeightForFooter must be set
@property (nonatomic, assign) CGFloat heightForFooter;
@property (nonatomic, readwrite) CGFloat estimatedHeightForHeader;
@property (nonatomic, readwrite) CGFloat estimatedHeightForFooter;
@property (nonatomic, readwrite) UIView *viewForHeader;
@property (nonatomic, readwrite) UIView *viewForFooter;
#pragma mark -
+ (NSString *)cellReuseIdentifierForHeader;
+ (NSString *)cellReuseIdentifierForFooter;

#pragma mark - UITableViewDelegate
- (void)willDisplayHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)willDisplayFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)didEndDisplayingHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0);
- (void)didEndDisplayingFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0);

#pragma mark - Convenient Methods
- (UITableView *)tableView;

#pragma mark - Accessor
- (id)objectInMutableRowItemsAtIndex:(NSUInteger)index;
- (void)removeObjectFromMutableRowItemsAtIndex:(NSUInteger)index;
- (void)replaceObjectInMutableRowItemsAtIndex:(NSUInteger)index withObject:(TMRowItem *)object;
- (void)insertObject:(TMRowItem *)object inMutableRowItemsAtIndex:(NSUInteger)index;

#pragma mark - Notify TableView
- (void)insertObject:(TMRowItem *)object inMutableRowItemsAtIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation;
- (void)removeObjectFromMutableRowItemsAtIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation;
@end
