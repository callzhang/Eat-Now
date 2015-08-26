//
//  GNMapOpener.h
//  GNMapOpenerExample
//
//  Created by Jakub Knejzlik on 09/04/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GNMapOpenerService.h"
#import "GNMapOpenerItem.h"

@interface GNMapOpener : NSObject

+(instancetype)sharedInstance;

-(void)openItem:(GNMapOpenerItem *)item presetingViewController:(UIViewController *)viewController;
-(void)openItem:(GNMapOpenerItem *)item withService:(GNMapOpenerService *)service;

-(NSArray *)availableServices;

@end
