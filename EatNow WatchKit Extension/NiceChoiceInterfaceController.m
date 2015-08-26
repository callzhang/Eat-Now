//
//  NiceChoiceInterfaceController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/13/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "NiceChoiceInterfaceController.h"


@interface NiceChoiceInterfaceController()

@end


@implementation NiceChoiceInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissController];
    });
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



