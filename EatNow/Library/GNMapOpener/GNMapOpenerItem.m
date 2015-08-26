//
//  GNMapOpenerOptions.m
//  GNMapOpenerExample
//
//  Created by Jakub Knejzlik on 09/04/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import "GNMapOpenerItem.h"

@implementation GNMapOpenerItem
@synthesize name = _name;

-(instancetype)initWithLocation:(CLLocation *)location{
    self = [super init];
    if (self) {
        _coordinate = location.coordinate;
    }
    return self;
}

@end
