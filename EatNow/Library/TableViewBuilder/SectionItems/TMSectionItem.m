//
//  TMSectionItem.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMSectionItem.h"
#import "TMRowItem+Protected.h"
#import "TMTableViewBuilder.h"


@interface TMSectionItem()
@property (nonatomic, strong) NSMutableArray *mutableRowItems;
//protected
@property (nonatomic, weak) TMTableViewBuilder *tableViewBuilder;
@end

@implementation TMSectionItem
- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableRowItems = [NSMutableArray array];
    }
    return self;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return self.mutableRowItems[index];
}

- (void)setObject:(TMRowItem *)obj atIndexedSubscript:(NSUInteger)index {
    NSParameterAssert([obj isKindOfClass:[TMRowItem class]]);
    [self insertObject:obj inMutableRowItemsAtIndex:index];
}

- (void)removeFromTableViewAnimated:(BOOL)animated {
    [self.tableViewBuilder removeSectionItem:self];
    if (self.section != NSNotFound) {
        UITableViewRowAnimation animation = animated ? UITableViewRowAnimationFade : UITableViewRowAnimationNone;
        [self.tableViewBuilder.tableView deleteSections:[NSIndexSet indexSetWithIndex:self.section] withRowAnimation:animation];
    }
}

- (void)removeFromTableView {
    [self removeFromTableViewAnimated:NO];
}

- (NSUInteger)indexOfRowItem:(TMRowItem *)rowItem {
    return [self.mutableRowItems indexOfObject:rowItem];
}

- (void)addRowItem:(TMRowItem *)rowItem {
    [self insertObject:rowItem inMutableRowItemsAtIndex:self.mutableRowItems.count];
}

- (void)insertObject:(TMRowItem *)object inMutableRowItemsAtIndex:(NSUInteger)index {
    object.sectionItem = self;
    [self.mutableRowItems insertObject:object atIndex:index];
}

- (void)replaceObjectInMutableRowItemsAtIndex:(NSUInteger)index withObject:(TMRowItem *)object {
    [self.mutableRowItems replaceObjectAtIndex:index withObject:object];
    object.sectionItem = self;
}

- (void)removeObjectFromMutableRowItemsAtIndex:(NSUInteger)index {
    [self.mutableRowItems removeObjectAtIndex:index];
}

- (id)objectInMutableRowItemsAtIndex:(NSUInteger)index {
    return [self.mutableRowItems objectAtIndex:index];
}

- (TMRowItem *)rowItemAtIndex:(NSUInteger)index {
    return self.mutableRowItems[index];
}

- (NSInteger)numberOfRows {
    return self.mutableRowItems.count;
}

- (void)removeRowItemAtIndex:(NSUInteger)index {
    [self.mutableRowItems removeObjectAtIndex:index];
}

- (UIView *)headerView {
    return nil;
}

+ (NSString *)cellReuseIdentifierForHeader {
    return nil;
}

+ (NSString *)cellReuseIdentifierForFooter {
    return nil;
}

- (UIView *)viewForHeader {
    if (!_viewForHeader) {
        NSString *identifier = [[self class] cellReuseIdentifierForHeader];
        UITableViewCell *cell = [self.tableViewBuilder.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell && identifier) {
            [self.tableViewBuilder.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
            cell = [self.tableViewBuilder.tableView dequeueReusableCellWithIdentifier:identifier];
        }
        _viewForHeader = cell;
    }
    return _viewForHeader;
}

- (UIView *)viewForFooter {
    if (!_viewForFooter) {
        NSString *identifier = [[self class] cellReuseIdentifierForFooter];
        UITableViewCell *cell = [self.tableViewBuilder.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell && identifier) {
            [self.tableViewBuilder.tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
            cell = [self.tableViewBuilder.tableView dequeueReusableCellWithIdentifier:identifier];
        }
        _viewForFooter = cell;
    }
    return _viewForFooter;
}

#pragma mark - UITableViewDataSource
#pragma mark - reload
- (void)reloadSectionWithAnimation:(UITableViewRowAnimation)animation {
    [self.tableViewBuilder.tableView reloadSections:[NSIndexSet indexSetWithIndex:self.section] withRowAnimation:animation];
}

#pragma mark - UITableViewDelegate
- (void)willDisplayHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0) {
    
}

- (void)willDisplayFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0) {
    
}

- (void)didEndDisplayingHeaderView:(UIView *)view NS_AVAILABLE_IOS(6_0) {
    
}

- (void)didEndDisplayingFooterView:(UIView *)view NS_AVAILABLE_IOS(6_0) {
    
}
#pragma mark - Convenient Methods
- (UITableView *)tableView {
    return self.tableViewBuilder.tableView;
}

- (NSInteger)section {
    return [self.tableViewBuilder indexOfSection:self];
}

#pragma mark - Notify TableView
- (void)insertObject:(TMRowItem *)object inMutableRowItemsAtIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation {
    NSParameterAssert(self.tableView);
    [self insertObject:object inMutableRowItemsAtIndex:index];
    [self.tableView insertRowsAtIndexPaths:@[object.indexPath] withRowAnimation:animation];
}

- (void)removeObjectFromMutableRowItemsAtIndex:(NSUInteger)index withRowAnimation:(UITableViewRowAnimation)animation {
    NSParameterAssert(self.tableView);
    TMRowItem *rowItem = [self rowItemAtIndex:index];
    NSIndexPath *indexPath = rowItem.indexPath;
    [self removeRowItemAtIndex:index];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
}

#pragma mark -

@end
