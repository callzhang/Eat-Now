//
//  ENLostConnectionViewController.m
//  EatNow
//
//  Created by Zitao Xiong on 5/9/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENLostConnectionViewController.h"
#import "EatNow-Swift.h"
#import "AFNetworkReachabilityManager.h"

@interface ENLostConnectionViewController ()
@property (weak, nonatomic) IBOutlet ApplicationButton *tryAgainButton;

@end

@implementation ENLostConnectionViewController
- (IBAction)onTryAgainButton:(id)sender {
    [self.tryAgainButton setTitle:@"Trying..." forState:UIControlStateNormal];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tryAgainButton setTitle:@"Try Again" forState:UIControlStateNormal];
    });
}

@end
