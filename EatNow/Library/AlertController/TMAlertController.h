//
//  TMAlertController.h
//  EatNow
//
//  Created by Zitao Xiong on 5/11/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TMAlartControllerStyle) {
    TMAlartControllerStyleAlert,
};

typedef NS_ENUM(NSUInteger, TMAlertControlerIconStyle) {
    TMAlertControlerIconStyleQustion,
    TMAlertControlerIconStyleThumbsUp,
    TMAlertControlerIconStylePhone,
};
@class TMAlertAction;
@interface TMAlertController : UIViewController
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, readonly) TMAlartControllerStyle preferredStyle;
@property (nonatomic, readonly) NSArray *actions;
@property (nonatomic, strong) UIImage *iconImage;

@property (nonatomic, assign) TMAlertControlerIconStyle iconStyle;

- (void)addAction:(TMAlertAction *)action;
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(TMAlartControllerStyle)preferredStyle;
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(TMAlartControllerStyle)preferredStyle;

@property (nonatomic, assign) CGFloat preferredWidth;

- (CGSize)preferredSizeFitsInWidth:(CGFloat)width;
@end
