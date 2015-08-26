//
//  NSError+TMError.m
//  TMBootstrap
//
//  Created by Zitao Xiong on 3/5/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "NSError+TMError.h"
#import "AFNetworking.h"

@implementation NSError (WJLL)
- (id)responseError{
    NSData *data = self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    if (!data) {
        NSLog(@"Error: cannot decode nil error data");
        return self;
    }
    
    NSError *jsonReadError;
    id dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonReadError];
    
    if (!jsonReadError) {
        return dictionary;
    }
    else {
        NSLog(@"Error: cannot read error: %@ for error object: %@", jsonReadError, self);
        return self;
    }
}

@end
