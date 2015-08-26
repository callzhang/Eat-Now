//
//  NSDate+Extension.h
//  EatNow
//
//  Created by Zitao Xiong on 4/18/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)
- (NSString *)string;
/**
 *  2012-04-23T18:25:43.511Z
 *
 *  @return ISO8601 date format
 */
- (NSString *)ISO8601;
- (NSString *)YYYYMMDD;
+ (NSDate *)dateFromISO1861:(NSString *)str;
@end
