//
//  UIViewController+Blur.m
//  EarlyWorm
//
//  Created by Lei on 3/23/14.
//  Copyright (c) 2014 Shens. All rights reserved.
//

#import "UIViewController+Blur.h"
#import "EWBlurNavigationControllerDelegate.h"

static EWBlurNavigationControllerDelegate *delegate = nil;

@implementation UIViewController (Blur)

- (void)presentViewControllerWithBlurBackground:(UIViewController *)viewController{
	
	[self presentViewControllerWithBlurBackground:viewController completion:NULL];
	
}

- (void)presentViewControllerWithBlurBackground:(UIViewController *)viewController completion:(VoidBlock)block{
	[self presentViewControllerWithBlurBackground:viewController option:EWBlurViewOptionBlack completion:block];
}


- (void)presentViewControllerWithBlurBackground:(UIViewController *)viewController option:(EWBlurViewOptions)blurOption completion:(VoidBlock)block{
	viewController.modalPresentationStyle = UIModalPresentationCustom;
	if (!delegate) {
		delegate = [EWBlurNavigationControllerDelegate new];
	}
	
	viewController.transitioningDelegate = delegate;
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *nav = (UINavigationController *)viewController;
		[nav setDelegate:delegate];
    }
	
	//hide status bar
	//[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

	[self presentViewController:viewController animated:YES completion:block];
}


- (void)dismissBlurViewControllerWithCompletionHandler:(void(^)(void))completion{
	
	//[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	

	[self dismissViewControllerAnimated:YES completion:completion];

}

//automatic presenting: if already has presented view, dismiss it first
- (void)presentWithBlur:(UIViewController *)controller withCompletion:(VoidBlock)completion{
	if (self.presentedViewController) {
		if ([self.presentedViewController isKindOfClass:[controller class]]) {
			DDLogInfo(@"The view controller %@ is already presenting, skip blur animation", controller.class);
			return;
		} 
		//need to dismiss first
		[self dismissBlurViewControllerWithCompletionHandler:^{
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				[self presentViewControllerWithBlurBackground:controller completion:completion];
			});
		}];
	}else{
		[self presentViewControllerWithBlurBackground:controller completion:completion];
	}
}


@end
