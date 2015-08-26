//
//  TMTableViewBuilder.h
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMSectionItem.h"
#import "TMRowItem.h"
#import "TMTableViewDataSource.h"
#import "TMTableViewDelegate.h"
@import UIKit;
@protocol TMTableViewDataSource <NSObject>
@optional
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;              // Default is 1 if not implemented

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;

// Editing

// Individual rows can opt out of having the -editing property set for them. If not implemented, all rows are assumed to be editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;

// Moving/reordering

// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

// Index

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView;                                                    // return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  // tell table which section corresponds to section title/index (e.g. "B",1))

// Data manipulation - insert and delete support

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
// Not called for edit actions using UITableViewRowAction - the action's handler will be invoked instead
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;
@end

typedef void(^TableViewReloadBlock)(TMTableViewBuilder *builder);

@interface TMTableViewBuilder : NSObject
@property (nonatomic, readonly, weak) UITableView *tableView;
@property (nonatomic, readonly) TMTableViewDataSource *tableViewDataSource;
@property (nonatomic, readonly) TMTableViewDelegate *tableViewDelegate;

@property (nonatomic, strong) NSArray *sectionIndexTitles;


#pragma mark - INIT
- (BOOL)isConfigured;
- (instancetype)initWithTableView:(UITableView *)tableView tableViewDataSourceOverride:(id<TMTableViewDataSource>)datasource tableViewDelegateOverride:(id<UITableViewDelegate>)delegate;
- (instancetype)initWithTableView:(UITableView *)tableView;
#pragma mark - KVC
- (void)insertObject:(TMSectionItem *)object inMutableSectionItemsAtIndex:(NSUInteger)index;
- (void)replaceObjectInMutableSectionItemsAtIndex:(NSUInteger)index withObject:(TMSectionItem *)object;
- (void)removeObjectFromMutableSectionItemsAtIndex:(NSUInteger)index;
- (void)removeSectionItem:(TMSectionItem *)item;
#pragma mark -
- (NSInteger)numberOfSections;
- (NSUInteger)indexOfSection:(TMSectionItem *)section;

- (TMSectionItem *)sectionItemAtIndex:(NSInteger)index;

- (TMRowItem *)rowItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)addSectionItem:(TMSectionItem *)sectionItem;

- (void)registerTableViewCellForTableView:(UITableView *)tableView;

+ (void)setGlobalTableViewConfiguration:(void (^)(UITableView *tableView))configuration;

#pragma mark -
- (void)removeAllSectionItems;
- (void)removeRowItemAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, copy) TableViewReloadBlock reloadBlock;
- (void)setReloadBlock:(TableViewReloadBlock)constructBlock;
- (void)reloadData;

- (void)configure;
@end
