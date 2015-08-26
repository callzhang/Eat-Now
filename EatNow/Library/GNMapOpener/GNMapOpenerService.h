//
//  GNMapOpenerService.h
//  GNMapOpenerExample
//
//  Created by Jakub Knejzlik on 09/04/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import "GNMapOpenerItem.h"

@interface GNMapOpenerService : NSObject

@property (nonatomic,readonly) NSString *name;

+(BOOL)isAvailable;

-(void)openItem:(GNMapOpenerItem *)item;

@end
