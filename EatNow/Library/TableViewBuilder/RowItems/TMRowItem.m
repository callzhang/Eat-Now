//
//  TMRowItem.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMRowItem.h"
#import "TMRowItem+Protected.h"
#import "TMTableViewBuilder.h"
#import "FBKVOController.h"
#import "FBKVOController+Binding.h"
#import "UITableView+RegisterRowItem.h"
#import "objc/runtime.h"
#import "DDLog.h"

@interface TMRowItem ()
@property (nonatomic, copy) NSString *reuseIdentifier;

#pragma mark - protected
@property (nonatomic, weak) TMSectionItem *sectionItem;
@end

@implementation TMRowItem
- (instancetype)init {
    self = [super init];
    if (self) {
        [self __setup];
    }
    return self;
}
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        self.reuseIdentifier = reuseIdentifier;
        [self __setup];
    }
    return self;
}

- (void)__setup {
    self.automaticallyDeselect = YES;
    self.heightForRow = 50;
    self.selectionStyle = UITableViewCellSelectionStyleDefault;
    self.editingStyleForRow = UITableViewRowAnimationNone;
    self.estimatedHeightForRow = UITableViewAutomaticDimension;
    self.shouldHighlightRow = YES;
}

+ (instancetype)item {
    if (![[self class] reuseIdentifier]) {
        return nil;
    }
    
    TMRowItem *item = [[[self class] alloc] initWithReuseIdentifier:[[self class] reuseIdentifier]];
    return item;
}

- (NSString *)reuseIdentifier {
    if (_reuseIdentifier) {
        return [_reuseIdentifier copy];
    }
    return [[self class] reuseIdentifier];
}

- (NSIndexPath *)indexPath {
    TMSectionItem *sectionItem = self.sectionItem;
    NSUInteger row = [sectionItem indexOfRowItem:self];
    if (row != NSNotFound && sectionItem.section != NSNotFound) {
        return [NSIndexPath indexPathForRow:row inSection:sectionItem.section];
    }
    
    return nil;
}
#pragma mark - UITableViewDataSource
- (UITableViewCell *)cellForRow {
    UITableView *tableView = self.tableView;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier];
    if (!cell) {
        [tableView registerRowItem:self];
        cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier];
        if (!cell) {
            DDLogError(@"cell is nil");
        }
    }
    
    cell.selectionStyle = self.selectionStyle;
    [cell unbind];
    cell.rowItem = self;
    self.cell = cell;
    
    return cell;
}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle {
    
}

- (void)moveRowToIndexPath:(NSIndexPath *)destinationIndexPath {
    
}
#pragma mark - UITableViewDelegate
- (void)willDisplayCell:(UITableViewCell *)cell {
    
}

- (void)didEndDisplayingCell:(UITableViewCell *)cell TMP_REQUIRES_SUPER {
    [self unbind];
    [cell unbind];
    cell.rowItem = nil;
}

- (void)accessoryButtonTappedForRow {
    
}

- (void)didHighlightRow {
    
}

- (void)didUnhighlightRow {
    
}

- (NSIndexPath *)willSelectRow {
    return self.indexPath;
}

- (NSIndexPath *)willDeselectRow {
    return self.indexPath;
}

- (void)didSelectRow {
    if (self.automaticallyDeselect) {
        [self deselectRowAnimated:YES];
    }
    if (self.didSelectRowHandler) {
        self.didSelectRowHandler(self);
    }
}

- (void)didDeselectRow {
    if (self.didDeselectRowHandler) {
        self.didDeselectRowHandler(self);
    }
}

- (void)willBeginEditingRow {
    
}

- (void)didEndEditingRow {
    
}

- (NSIndexPath *)targetIndexPathForMoveFromRowToProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    return proposedDestinationIndexPath;
}

- (BOOL)shouldShowMenuForRow NS_AVAILABLE_IOS(5_0) {
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender NS_AVAILABLE_IOS(5_0) {
    return NO;
}

- (void)performAction:(SEL)action withSender:(id)sender NS_AVAILABLE_IOS(5_0) {
    
}

#pragma mark Manipulating table view row
- (void)selectRowAnimated:(BOOL)animated {
    [self selectRowAnimated:animated scrollPosition:UITableViewScrollPositionNone];
}

- (void)selectRowAnimated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
    [self.sectionItem.tableViewBuilder.tableView selectRowAtIndexPath:self.indexPath animated:animated scrollPosition:scrollPosition];
}

- (void)deselectRowAnimated:(BOOL)animated {
    [self.sectionItem.tableViewBuilder.tableView deselectRowAtIndexPath:self.indexPath animated:animated];
}

- (void)reloadRowWithAnimation:(UITableViewRowAnimation)animation {
    [self.sectionItem.tableViewBuilder.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:animation];
}

- (void)deleteRowWithAnimation:(UITableViewRowAnimation)animation {
    NSIndexPath *indexPath = self.indexPath;
    [self.sectionItem removeRowItemAtIndex:indexPath.row];
    [self.sectionItem.tableViewBuilder.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];

}
#pragma mark - Subclassing
+ (NSString *)reuseIdentifier {
    return nil;
}

#pragma mark - Convenient Methods
- (UITableView *)tableView {
    return self.sectionItem.tableView;
}
@end

@implementation UITableViewCell (TMRowItem)

- (id)rowItem {
    return objc_getAssociatedObject(self, @selector(rowItem));
}

- (void)setRowItem:(TMRowItem *)rowItem {
    objc_setAssociatedObject(self, @selector(rowItem), rowItem, OBJC_ASSOCIATION_RETAIN);
}

@end