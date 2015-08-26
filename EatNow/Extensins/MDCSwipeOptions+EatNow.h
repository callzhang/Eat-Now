//
//  MDCSwipeOptions+EatNow.h
//  EatNow
//
//  Created by Lee on 2/12/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "MDCSwipeOptions.h"

typedef void (^MDCSwipeToChooseOnTapBlock)(UITapGestureRecognizer *gesture);
@interface MDCSwipeOptions(EatNow)
@property (nonatomic, copy) MDCSwipeToChooseOnTapBlock onTap;
@end
