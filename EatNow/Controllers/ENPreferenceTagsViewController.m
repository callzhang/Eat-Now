//
//  ENPreferenceTagsViewController.m
//  EatNow
//
//  Created by Lee on 7/19/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENPreferenceTagsViewController.h"
#import "JCTagListView.h"
#import "ENServerManager.h"

@interface ENPreferenceTagsViewController ()
@property (weak, nonatomic) IBOutlet JCTagListView *tagView;
@property (assign, nonatomic) BOOL preSelected;
@property (weak, nonatomic) IBOutlet UILabel *tasteDescription;
@end

@implementation ENPreferenceTagsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(close:)];
    self.tagView.canSeletedTags = YES;
    [self.tagView.tags addObjectsFromArray:kBasePreferencesValue];
    self.tagView.collectionView.backgroundColor = [UIColor clearColor];
    [self.tagView setCompletionBlockWithSeleted:^(BOOL selected, NSInteger index) {
        DDLogDebug(@"%@%ld", selected?@"Select":@"De-select", (long)index);
    }];
        
    self.tagView.backgroundColor = [UIColor clearColor];
    
    //set text
    NSDictionary *preference = [ENServerManager shared].preference;
    if (preference) {
        [self setTextForPreference:preference];
    } else {
        [[NSNotificationCenter defaultCenter] addObserverForName:kPreferenceUpdated object:nil queue:nil usingBlock:^(NSNotification *note) {
            NSDictionary *pref = note.object;
            [self setTextForPreference:pref];
        }];
    }
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.preSelected) {
        DDLogVerbose(@"Already preselected");
        return;
    }else {
        self.preSelected = YES;
    }
    //add selection
    NSDictionary *base = [ENServerManager shared].basePreference;
    [base enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *score, BOOL *stop) {
        if (score.floatValue == 0) return;
        NSUInteger idx = [kBasePreferences indexOfObject:key];
        if (idx != NSIntegerMax) {
            DDLogVerbose(@"Pre-select %@: (%lu)", key, (unsigned long)idx);
            [self.tagView.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        }
    }];
}

- (void)viewDidDisappear:(BOOL)animated{
    NSArray *selection = self.tagView.collectionView.indexPathsForSelectedItems;
    DDLogVerbose(@"Selected: %@", selection);
    
    NSMutableDictionary *pref = [NSMutableDictionary dictionary];
    for (NSIndexPath *idx in selection) {
        NSString *cuisine = kBasePreferences[idx.row];
        pref[cuisine] = @3;
    }
    
    if ([pref isEqualToDictionary:[ENServerManager shared].basePreference]) {
        DDLogVerbose(@"Skip updating same base pref");
        return;
    }
    [[ENServerManager shared] updateBasePreference:pref completion:^(NSError *error) {
        //DDLogVerbose(@"Base preference updated: %@", pref);
        if (error) {
            [self.presentingViewController.view showFailureNotification:@"Failed to update base preference"];
        }
        //broadcast
        [[NSNotificationCenter defaultCenter] postNotificationName:kBasePreferenceUpdated object:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UI
- (IBAction)close:(id)sender{
    if (self.navigationController) {
        [self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    }
}

- (void)setTextForPreference:(NSDictionary *)preference {
    if ([ENServerManager shared].history.count == 0) {
        //no history
        self.tasteDescription.text = @"Your have no dine history, and thus we don't know your taste yet. You can add addtional tastes from below.";
        return;
    }
    NSMutableArray *cuisines = preference.allKeys.mutableCopy;
    [cuisines sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        NSNumber *score1 = preference[obj1];
        NSNumber *score2 = preference[obj2];
        return [score2 compare:score1];
    }];
    
    NSNumber *topScore = preference[cuisines[0]];
    if (topScore.floatValue != 0) {
        self.tasteDescription.text = [NSString stringWithFormat:@"Your current top choices are: %@, %@ and %@. In addtion to that, you can add more tastes from below.", cuisines[0], cuisines[1], cuisines[2]];
    } else {
        self.tasteDescription.text = @"YOu haven't told us where you've been to, and thus we don't know your taste yet. You can add addtional tastes from below.";
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
