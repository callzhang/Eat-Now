//
//  NSDate+Extension.m
//  EatNow
//
//  Created by Zitao Xiong on 4/18/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)


- (NSString *)string{
    NSDateFormatter *parseFormatter = [[NSDateFormatter alloc] init];
    parseFormatter.timeZone = [NSTimeZone defaultTimeZone];
    parseFormatter.dateFormat = @"MMM d, yyyy";

    return [parseFormatter stringFromDate:self];
}

- (NSString *)ISO8601 {
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone defaultTimeZone];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssxxx"];
    NSString *string = [formatter stringFromDate:self];
    return string;
}

+ (NSDate *)dateFromISO1861:(NSString *)str{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone defaultTimeZone];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ssxxx"];
    NSDate *date = [formatter dateFromString:str];
    if (!date) {
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"];
        date = [formatter dateFromString:str];
    }

    return date;
}

- (NSString *)YYYYMMDD{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone defaultTimeZone];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *string = [formatter stringFromDate:self];
    return string;
}

@end
