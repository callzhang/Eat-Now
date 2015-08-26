//
//  TMAlertAction.h
//  EatNow
//
//  Created by Zitao Xiong on 5/11/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TMAlertActionStyle) {
    TMAlertActionStyleDefault,
    TMAlertActionStyleCancel,
    TMAlertActionStyleDestructive,
};

@interface TMAlertAction : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) TMAlertActionStyle style;
@property (nonatomic, assign, getter=isEnabled) BOOL enabled;

+ (instancetype)actionWithTitle:(NSString *)title style:(TMAlertActionStyle)style handler:(void (^)(TMAlertAction *action))handler;
- (instancetype)initWithTitle:(NSString *)title style:(TMAlertActionStyle)style handler:(void (^)(TMAlertAction *action))handler;


@property (nonatomic, weak) UIButton *associatedButton;
@property (nonatomic, copy) void (^handler)(TMAlertAction *);
@end
