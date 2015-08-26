//
//  TMAlertController.m
//  EatNow
//
//  Created by Zitao Xiong on 5/11/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "TMAlertController.h"
#import "TMAlertAction.h"
#import "PureLayout.h"
#import "TMAlertTransitioningDelegate.h"

@interface TMAlertController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageTextLabel;
@property (nonatomic, strong) NSMutableArray *mutableActions;
@property (nonatomic, assign) TMAlartControllerStyle preferredStyle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageLabelLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIView *backgroundContainerView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualEffectBackgroundView;
@property (nonatomic, strong) TMAlertTransitioningDelegate *transitionDelegate;
@end

@implementation TMAlertController
@dynamic title;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(TMAlartControllerStyle)preferredStyle {
    TMAlertController *controller = [[TMAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
    return controller;
}

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(TMAlartControllerStyle)preferredStyle {
    self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
    if (self) {
        self.title = title;
        self.message = message;
        self.preferredStyle = preferredStyle;
        
        self.transitionDelegate = [[TMAlertTransitioningDelegate alloc] init];
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self.transitionDelegate;
        self.iconStyle = TMAlertControlerIconStyleQustion;

    }
    
    return self;
}

- (NSMutableArray *)mutableActions {
    if (!_mutableActions) {
        _mutableActions = [NSMutableArray array];
    }
    return _mutableActions;
}

- (NSArray *)actions {
    return self.mutableActions.copy;
}

- (void)addAction:(TMAlertAction *)action {
    [self.mutableActions addObject:action];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleTextLabel.text = self.title;
    self.messageTextLabel.text = self.message;
    self.iconImageView.image = self.iconImage;
    
    if (self.title.length != 0) {
        self.messageLabelLayoutConstraint.constant = 108;
    }
    else {
        self.messageLabelLayoutConstraint.constant = 68;
    }
    
    NSMutableArray *alignmentViews = [NSMutableArray array];
    for (TMAlertAction *action in self.mutableActions) {
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionButton setTitle:action.title forState:UIControlStateNormal];
        actionButton.enabled = action.enabled;
        [self.view addSubview:actionButton];
        [alignmentViews addObject:actionButton];
        [self configuraButton:actionButton];
        
        [actionButton addTarget:self action:@selector(onButtonTouchedUpInside:) forControlEvents:UIControlEventTouchUpInside];
        action.associatedButton = actionButton;
    }
    
    [alignmentViews autoSetViewsDimension:ALDimensionHeight toSize:44.0];
    
    if (alignmentViews.count > 1) {
        [alignmentViews autoDistributeViewsAlongAxis:ALAxisHorizontal
                                           alignedTo:ALAttributeBottom
                                    withFixedSpacing:10
                                        insetSpacing:5 matchedSizes:YES];
        [[alignmentViews firstObject] autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
    }
    else if (alignmentViews.count == 1){
        UIView *view = alignmentViews.firstObject;
        [view autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20];
        [view autoPinEdgeToSuperviewMargin:ALEdgeLeading];
        [view autoPinEdgeToSuperviewMargin:ALEdgeTrailing];
        [view autoAlignAxisToSuperviewAxis:ALAxisVertical];
    }
    
    self.backgroundContainerView.layer.cornerRadius = 8;
}

- (void)configuraButton:(UIButton *)button {
    CGFloat onePixel = 1.0 / [UIScreen mainScreen].scale;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = onePixel;
    button.layer.cornerRadius = 4.0;
}

- (void)onButtonTouchedUpInside:(UIButton *)button {
    TMAlertAction *action = nil;
    for (TMAlertAction *a in self.actions) {
        if (a.associatedButton == button) {
            action = a;
            break;
        }
    }
    
    if (action.handler) {
        action.handler(action);
    }
}

- (CGSize)preferredSizeFitsInWidth:(CGFloat)width {
    CGFloat labelHeight1 = ENExpectedLabelHeight(self.titleTextLabel, width);
    CGFloat labelHeight2 = ENExpectedLabelHeight(self.messageTextLabel, width);
    CGFloat titleLabelTop = 68;
    CGFloat labelSpacing = 30;
    CGFloat labelBottom = 88;
    
    return CGSizeMake(width, labelHeight1 + labelHeight2 + titleLabelTop + labelSpacing + labelBottom);
}

- (void)setIconStyle:(TMAlertControlerIconStyle)iconStyle {
    switch (iconStyle) {
        case TMAlertControlerIconStyleQustion: {
            self.iconImage = [UIImage imageNamed:@"eat-now-alert-question-mark-icon"];
            break;
        }
        case TMAlertControlerIconStyleThumbsUp: {
            self.iconImage = [UIImage imageNamed:@"eat-now-alert-thumbsup-icon"];
            break;
        }
        case TMAlertControlerIconStylePhone: {
            self.iconImage = [UIImage imageNamed:@"eat-now-alert-phone-icon"];
            break;
        }
        default: {
            break;
        }
    }
}
@end
