//
//  NSError+EatNow.h
//  EatNow
//
//  Created by Zitao Xiong on 5/9/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kEatNowErrorDomain;

typedef NS_ENUM(NSInteger, EatNowErrorType) {
    EatNowErrorTypeServerError = -888,
    EatNowErrorTypeLocaltionNotAvailable = -999,
};

@interface NSError (EatNow)

@end
