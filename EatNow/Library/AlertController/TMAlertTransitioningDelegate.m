//
//  TMAlertTransitioningDelegate.m
//  EatNow
//
//  Created by Zitao Xiong on 5/11/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "TMAlertTransitioningDelegate.h"
#import "TMAlertPresentationController.h"

@implementation TMAlertTransitioningDelegate
- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    UIPresentationController *pc = [[TMAlertPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    return pc;
}
@end
