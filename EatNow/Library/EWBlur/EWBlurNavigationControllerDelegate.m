//
//  NavigationControllerDelegate.h
//  NavigationTransitionController
//
//  Created by Lei Zhang 7/12/2014
//  Copyright (c) 2014 BlackFog. All rights reserved.
//

#import "EWBlurNavigationControllerDelegate.h"
#import "EWBlurAnimator.h"

static NSString * PushSegueIdentifier = @"push segue identifier";

@interface EWBlurNavigationControllerDelegate ()

@property (weak, nonatomic) IBOutlet UINavigationController *navigationController;
@property (strong, nonatomic) EWBlurAnimator* animator;
@property (strong, nonatomic) UIPercentDrivenInteractiveTransition* interactionController;

@end

@implementation EWBlurNavigationControllerDelegate

- (void)awakeFromNib
{
//    UIPanGestureRecognizer* panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//    [self.navigationController.view addGestureRecognizer:panRecognizer];
    self.animator = [EWBlurAnimator new];
}


- (EWBlurNavigationControllerDelegate *)init{
    self = [super init];
    self.animator = [EWBlurAnimator new];
    return self;
}

//- (void)pan:(UIPanGestureRecognizer*)recognizer
//{
//    UIView* view = self.navigationController.view;
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        CGPoint location = [recognizer locationInView:view];
//        if (location.x > CGRectGetMidX(view.bounds) && self.navigationController.viewControllers.count == 1){
//            self.interactionController = [UIPercentDrivenInteractiveTransition new];
//            [self.navigationController.visibleViewController performSegueWithIdentifier:PushSegueIdentifier sender:self];
//        }
//    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
//        CGPoint translation = [recognizer translationInView:view];
//        // fabs() 求浮点数的绝对值
//        CGFloat d = fabs(translation.x / CGRectGetWidth(view.bounds));
//        [self.interactionController updateInteractiveTransition:d];
//    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        if ([recognizer velocityInView:view].x < 0) {
//            [self.interactionController finishInteractiveTransition];
//        } else {
//            [self.interactionController cancelInteractiveTransition];
//        }
//        self.interactionController = nil;
//    }
//}

#pragma mark - UINavigationViewControllerDelegate
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        self.animator.type = UINavigationControllerOperationPush;
        return self.animator;
    }else if (operation == UINavigationControllerOperationPop){
        self.animator.type = UINavigationControllerOperationPop;
        return self.animator;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    return self.interactionController;
}

#pragma mark - UIViewController transitioning
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    self.animator.type = kModelViewPresent;
    return self.animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissedZ{
    self.animator.type = kModelViewDismiss;
    return self.animator;
}


@end
