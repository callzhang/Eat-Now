//
//  TMTableViewBuilder.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMTableViewBuilder.h"
#import "TMSectionItem+Protected.h"
#import "TMSectionItem.h"
#import "DDLog.h"

static void (^_globalTableViewConfigurationBlock)(UITableView *tableView);

@interface TMTableViewBuilder ()
@property (nonatomic, strong) NSMutableArray *mutableSectionItems;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, assign, getter = isConfigured) BOOL configured;
@end

@implementation TMTableViewBuilder
@synthesize tableViewDataSource = _tableViewDataSource;
@synthesize tableViewDelegate = _tableViewDelegate;

- (instancetype)initWithTableView:(UITableView *)tableView {
    return [self initWithTableView:tableView tableViewDataSourceOverride:nil tableViewDelegateOverride:nil];
}

- (instancetype)initWithTableView:(UITableView *)tableView tableViewDataSourceOverride:(id <TMTableViewDataSource> )datasource tableViewDelegateOverride:(id <UITableViewDelegate> )delegate {
    self = [self init];
    if (self) {
        if (!tableView) {
            DDLogError(@"no table view passed in, need to configure it later");
        }
        self.tableViewDelegate.delegate = delegate;
        self.tableViewDataSource.dataSource = datasource;
        tableView.delegate = self.tableViewDelegate;
        tableView.dataSource = self.tableViewDataSource;
        
        self.tableView = tableView;
    }
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.mutableSectionItems = [NSMutableArray array];
    }
    return self;
}

#pragma mark - KVC
- (void)insertObject:(TMSectionItem *)object inMutableSectionItemsAtIndex:(NSUInteger)index {
    [self.mutableSectionItems insertObject:object atIndex:index];
}

- (void)replaceObjectInMutableSectionItemsAtIndex:(NSUInteger)index withObject:(TMSectionItem *)object {
    [self.mutableSectionItems replaceObjectAtIndex:index withObject:object];
}

- (void)removeObjectFromMutableSectionItemsAtIndex:(NSUInteger)index {
    [self.mutableSectionItems removeObjectAtIndex:index];
}

- (void)removeAllSectionItems {
    [self.mutableSectionItems removeAllObjects];
}

- (void)removeRowItemAtIndexPath:(NSIndexPath *)indexPath {
    TMSectionItem *sectionItem = [self.mutableSectionItems objectAtIndex:indexPath.section];
    [sectionItem removeRowItemAtIndex:indexPath.row];
}

- (void)removeSectionItem:(TMSectionItem *)item {
    NSInteger index = [self.mutableSectionItems indexOfObject:item];
    if (index != NSNotFound) {
        [self removeObjectFromMutableSectionItemsAtIndex:index];
    }
}

#pragma mark - kyed subscript
- (id)objectAtIndexedSubscript:(NSUInteger)index {
    return self.mutableSectionItems[index];
}

- (void)setObject:(TMSectionItem *)obj atIndexedSubscript:(NSUInteger)index {
    NSParameterAssert([obj isKindOfClass:[TMSectionItem class]]);
    self.mutableSectionItems[index] = obj;
    obj.tableViewBuilder = self;
}

#pragma mark -

- (NSInteger)numberOfSections {
    return self.mutableSectionItems.count;
}

- (TMSectionItem *)sectionItemAtIndex:(NSInteger)index {
    TMSectionItem *sectionItem =  self.mutableSectionItems[index];
    return sectionItem;
}

- (TMRowItem *)rowItemAtIndexPath:(NSIndexPath *)indexPath {
    TMSectionItem *sectionItem = [self sectionItemAtIndex:indexPath.section];
    TMRowItem *rowItem = [sectionItem rowItemAtIndex:indexPath.row];
    return rowItem;
}

- (void)addSectionItem:(TMSectionItem *)sectionItem {
    NSParameterAssert([sectionItem isKindOfClass:[TMSectionItem class]]);
    [self insertObject:sectionItem inMutableSectionItemsAtIndex:self.mutableSectionItems.count];
    sectionItem.tableViewBuilder = self;
}

- (NSUInteger)indexOfSection:(TMSectionItem *)section {
    return [self.mutableSectionItems indexOfObject:section];
}

- (TMTableViewDataSource *)tableViewDataSource {
    if (!_tableViewDataSource) {
        _tableViewDataSource = [[TMTableViewDataSource alloc] initWithTableViewBuilder:self];
    }
    return _tableViewDataSource;
}

- (TMTableViewDelegate *)tableViewDelegate {
    if (!_tableViewDelegate) {
        _tableViewDelegate = [[TMTableViewDelegate alloc] initWithTableViewBuilder:self];
    }
    return _tableViewDelegate;
}

- (void)registerTableViewCellForTableView:(UITableView *)tableView {
    NSMutableSet *identifiers = [NSMutableSet set];
    for (TMSectionItem *sectionItem in self.mutableSectionItems) {
        for (NSInteger i = 0; i < sectionItem.numberOfRows; i++) {
            TMRowItem *rowItem = [sectionItem rowItemAtIndex:i];
            [identifiers addObject:[rowItem reuseIdentifier]];
        }
    }
    
    for (NSString *reuseIdentifier in identifiers) {
        [tableView registerNib:[UINib nibWithNibName:reuseIdentifier bundle:nil] forCellReuseIdentifier:reuseIdentifier];
    }
}

- (void)configure {
    self.configured = YES;
    
    [self reloadData];
    
    [self registerTableViewCellForTableView:self.tableView];
    
    if (_globalTableViewConfigurationBlock) {
        _globalTableViewConfigurationBlock(self.tableView);
    }
}

- (void)reloadData {
    if (self.reloadBlock) {
        self.reloadBlock(self);
    }
    [self.tableView reloadData];
}

+ (void)setGlobalTableViewConfiguration:(void (^)(UITableView *))configuration {
    _globalTableViewConfigurationBlock = configuration;
}

@end
