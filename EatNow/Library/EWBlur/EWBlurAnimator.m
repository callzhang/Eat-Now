//
//  GPUBlurAnimator.h
//  WokeAlarm
//
//  Created by Lei Zhang on 9/28/13.
//  Copyright (c) 2013 Woke. All rights reserved.
//

#import "EWBlurAnimator.h"
#import "GPUImage.h"
#import "GPUImagePicture.h"
#import "GPUImagePixellateFilter.h"
#import "GPUImageView.h"
#import "UIViewController+Blur.h"
#import "GPUImageTransformFilter.h"
#import "GPUImageToneCurveFilter.h"
#import "GPUImageNormalBlendFilter.h"
#import "UIView+Extend.h"
#import "UIView+screenshot.h"

static const CGFloat duration = 0.3;
static const CGFloat delay = 0.1;
static const CGFloat zoom = 1.5;
static const CGFloat initialDownSampling = 2;


@interface EWBlurAnimator (){
	UIViewController* toViewController;
	UIViewController* fromViewController;
	UIView* container;
	UIView *fromView;
	UIView *toView;
}

@property (nonatomic, strong) GPUImagePicture* blurImage;
//@property (nonatomic, strong) GPUImageTransformFilter *zoomFilter;
@property (nonatomic, strong) GPUImageiOSBlurFilter* blurFilter;
@property (nonatomic, strong) GPUImageToneCurveFilter* brightnessFilter;
@property (nonatomic, strong) GPUImageView* currentGPUImageView;
@property (nonatomic, strong) id <UIViewControllerContextTransitioning> context;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic, strong) CADisplayLink* displayLink;
@property (nonatomic, strong) NSMutableArray *GPUImageViews;
@end

@implementation EWBlurAnimator

- (id)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
	//blurFilter->BrightnessFilter->GPUImageView
	self.GPUImageViews = [NSMutableArray array];
    self.blurFilter = [[GPUImageiOSBlurFilter alloc] init];
    self.blurFilter.rangeReductionFactor = 0;
    self.brightnessFilter = [[GPUImageToneCurveFilter alloc] init];
	
    [self.blurFilter addTarget:self.brightnessFilter];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateFrame:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    self.displayLink.paused = YES;
}


- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return duration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.context = transitionContext;
    toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	container = [transitionContext containerView];
	fromView = fromViewController.view;
	toView = toViewController.view;
	
	

	//init timer
	self.startTime = 0;
	
    if (self.type == UINavigationControllerOperationPush || self.type == kModelViewPresent) {
		
		//remove background color & image
		toView.backgroundColor = [UIColor clearColor];
		[[toView viewWithTag:kBackgroundImageTag] removeFromSuperview];
		toViewController.view.backgroundColor = [UIColor clearColor];
		if ([toViewController isKindOfClass:[UINavigationController class]]) {
			UINavigationController *nav = (UINavigationController *)toViewController;
			nav.visibleViewController.view.backgroundColor = [UIColor clearColor];
			[[nav.visibleViewController.view viewWithTag:kBackgroundImageTag] removeFromSuperview];
		}
		
		//add GPU image view
		self.currentGPUImageView = [[GPUImageView alloc] init];
		//self.currentGPUImageView.tag = kGPUImageViewTag;
		self.currentGPUImageView.frame = container.bounds;
		self.currentGPUImageView.backgroundColor = [UIColor clearColor];
		self.currentGPUImageView.alpha = 1;
		if (self.GPUImageViews.count) {
			GPUImageView *lastGPUImageView = self.GPUImageViews.lastObject;
			[container insertSubview:self.currentGPUImageView aboveSubview:lastGPUImageView];
		}else{
			[container insertSubview:self.currentGPUImageView atIndex:0];
		}
		[self.GPUImageViews addObject:self.currentGPUImageView];
		
		//add filter to current GPU image view
		[self.brightnessFilter removeAllTargets];
		[self.brightnessFilter addTarget:self.currentGPUImageView];
		
        //pre animation toView set up
        toView.alpha = 0.01;
        toView.transform = CGAffineTransformMakeScale(zoom, zoom);
        [container addSubview:toView];
        
        //GPU image setup
        UIImage *fromViewImage = fromView.screenshot;
		self.blurImage = [[GPUImagePicture alloc] initWithImage:fromViewImage];
		[self.blurImage addTarget:self.blurFilter];
		
		//update first frame so the transition will be smoother
		[self updateFrame:nil];
        
        //trigger GPU rendering
        self.displayLink.paused = NO;
        
        //animation
        [UIView animateWithDuration:duration delay:delay + 0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            toView.alpha = 1;
            toView.transform = CGAffineTransformIdentity;
        } completion:NULL];
        
        
    }else if(self.type == UINavigationControllerOperationPop || self.type == kModelViewDismiss){
		NSParameterAssert(self.GPUImageViews.count > 0);
		self.currentGPUImageView = self.GPUImageViews.lastObject;
		
		//take a new screenshot and render the imageView
		UIImage *toViewImage = toView.screenshot;
		self.blurImage = [[GPUImagePicture alloc] initWithImage:toViewImage];
        [self.blurImage addTarget:self.blurFilter];
		[self updateFrame:nil];
		
		fromView.transform = CGAffineTransformIdentity;
		
        [UIView animateWithDuration:duration-delay animations:^{
            
            fromView.alpha = 0;
            fromView.transform = CGAffineTransformMakeScale(zoom, zoom);
            
        }completion:^(BOOL finished) {
            
            [fromView removeFromSuperview];
            
        }];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			//start the animation
            self.displayLink.paused = NO;
        });
    }
}

- (void)triggerRenderOfNextFrame
{
	BOOL active = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
	if (active) {
		[self.blurImage processImage];
	}
}

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    [self animateTransition:transitionContext];
}

- (void)updateFrame:(CADisplayLink*)link
{
    [self updateProgress:link];
	//[self.zoomFilter setAffineTransform:CGAffineTransformMakeScale(1 - 0.05 * _progress, 1 - 0.05 * _progress)];
	[self.brightnessFilter setRgbCompositeControlPoints:@[[NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
												[NSValue valueWithCGPoint:CGPointMake(0.3, 0.3 - 0.1 * _progress)],
												[NSValue valueWithCGPoint:CGPointMake(0.7, 0.7 - 0.3 * _progress)],
												[NSValue valueWithCGPoint:CGPointMake(1.0, 1.0 - 0.4 * _progress)]]];
	self.blurFilter.saturation = 1 + 0.2 * _progress;
    self.blurFilter.downsampling = initialDownSampling + _progress * 4;
    self.blurFilter.blurRadiusInPixels = 1 + _progress * 9;
    [self triggerRenderOfNextFrame];
	
    if ((self.type == UINavigationControllerOperationPush || self.type == kModelViewPresent)) {
		if (_progress>0) {
			fromView.alpha = 0;
		}
			
		if (_progress == 1) {
			self.displayLink.paused = YES;
			[self.context completeTransition:YES];
		}
		
    }else if (_progress == 0 && (self.type == UINavigationControllerOperationPop || self.type == kModelViewDismiss)){
        
        //=======> dismiss animation ended
        
        //unhide to view'
        self.displayLink.paused = YES;
        [self.context completeTransition:YES];
		[self.GPUImageViews removeObject:self.currentGPUImageView];
		
        if (self.type == UINavigationControllerOperationPop) {
			[[self.context containerView] addSubview:toView];
			self.currentGPUImageView.alpha = 0;
		}else{
			[self.currentGPUImageView removeFromSuperview];
		}
		
		//make toView visible
		toView.alpha = 1;
		toView.hidden = NO;
        
    }
}

//update progress
- (void)updateProgress:(CADisplayLink*)link
{
    if (self.interactive) return;
	CGFloat progress;
	
    if (self.startTime == 0) {
        self.startTime = link.timestamp;
    }
	
	if (link) {
		progress = MAX(0, MIN((link.timestamp - self.startTime) / duration, 1));
	}else{
		//used for precalculation
		progress = 0;
	}
    
    if (self.type == UINavigationControllerOperationPush || self.type == kModelViewPresent) {
        _progress = progress;
    }else if (self.type == UINavigationControllerOperationPop || self.type == kModelViewDismiss){
        _progress = 1- progress;
    }
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (self.interactive) {
        [self.context updateInteractiveTransition:progress];
    }
}

- (void)finishTransition
{
    self.displayLink.paused = YES;
    if (self.interactive) {
        [self.context finishInteractiveTransition];
    }
    
}

- (void)cancelInteractiveTransition
{
    // TODO: [Lei]
}

- (void)animationEnded:(BOOL)transitionCompleted{
	BOOL active = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
	if (self.type == kModelViewPresent && !active) {
		//rander the last frame when app become active
		__weak EWBlurAnimator *weakSelf = self;
		__block id observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
			DDLogInfo(@"Application did become active, render last frame of presenting blur image");
			weakSelf.blurImage = [[GPUImagePicture alloc] initWithImage:fromView.screenshot];
			[weakSelf.blurImage processImage];
			[[NSNotificationCenter defaultCenter] removeObserver:observer];
		}];

	}
    self.displayLink.paused = YES;
}

- (void)dealloc{
	if (self.displayLink) {
		[self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
	}
}

@end