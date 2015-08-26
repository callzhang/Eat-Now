//
//  TMTableViewDataSource.m
//  VideoGuide
//
//  Created by Zitao Xiong on 4/1/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMTableViewDataSource.h"
#import "TMTableViewBuilder.h"
#import "UITableView+RegisterRowItem.h"

@protocol TMTableViewProtocol <NSObject>
// Index
- (NSArray *)sectionIndexTitles; // return list of section titles to display in section index view (e.g. "ABCD...Z#")
- (NSInteger)numberOfSections;              // Default is 1 if not implemented
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;  // tell table which section corresponds to section title/index (e.g. "B",1))
@end

@interface TMTableViewDataSource()
@property (nonatomic, weak) TMTableViewBuilder *tableViewBuilder;
@end


@implementation TMTableViewDataSource
- (instancetype)initWithTableViewBuilder:(TMTableViewBuilder *)tableviewBuilder {
    self = [super init];
    if (self) {
        self.tableViewBuilder = tableviewBuilder;
    }
    
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.tableViewBuilder.isConfigured) {
        [self.tableViewBuilder configure];
    }
    
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        return [self.dataSource numberOfSectionsInTableView:tableView];
    }
    
    return self.tableViewBuilder.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        return [self.dataSource tableView:tableView numberOfRowsInSection:section];
    }
    
    TMSectionItem *sectionItem = [self.tableViewBuilder sectionItemAtIndex:section];
    return sectionItem.numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)]) {
        return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return [rowItem cellForRow];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [self.dataSource tableView:tableView titleForHeaderInSection:section];
    }
    
    TMSectionItem *sectionItem = [self.tableViewBuilder sectionItemAtIndex:section];
    return sectionItem.titleForHeader;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        return [self.dataSource tableView:tableView titleForFooterInSection:section];
    }
    
    TMSectionItem *sectionItem = [self.tableViewBuilder sectionItemAtIndex:section];
    return sectionItem.titleForFooter;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [self.dataSource tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
        return;
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    [rowItem commitEditingStyle:editingStyle];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if ([self.dataSource respondsToSelector:@selector(sectionIndexTitlesForTableView:)]) {
        return [self.dataSource sectionIndexTitlesForTableView:tableView];
    }
    
    return self.tableViewBuilder.sectionIndexTitles;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [self.dataSource tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    
    TMRowItem *rowItem = [self.tableViewBuilder rowItemAtIndexPath:indexPath];
    return rowItem.canEdit;
}

// Moving/reordering

/** pending implementation
// Allows the reorder accessory view to optionally be shown for a particular row. By default, the reorder control will be shown only if the datasource implements -tableView:moveRowAtIndexPath:toIndexPath:
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
}

// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    
}
 **/
@end
