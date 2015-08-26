//
//  TMAlertAction.m
//  EatNow
//
//  Created by Zitao Xiong on 5/11/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "TMAlertAction.h"
@interface TMAlertAction()
@end

@implementation TMAlertAction
- (instancetype)initWithTitle:(NSString *)title style:(TMAlertActionStyle)style handler:(void (^)(TMAlertAction *))handler {
    self = [super init];
    if (self) {
        self.title = title;
        self.style = style;
        self.handler = handler;
        self.enabled = YES;
    }
    return self;
}

+ (instancetype)actionWithTitle:(NSString *)title style:(TMAlertActionStyle)style handler:(void (^)(TMAlertAction *))handler {
    TMAlertAction *action = [[self alloc] initWithTitle:title style:style handler:handler];
    return action;
}
@end
