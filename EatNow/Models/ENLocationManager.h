//
//  ENLocationManager.h
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ENServer.h"
#import "GCDSingleton.h"
#import "INTULocationManager.h"

ENLocationStatus enLocationStatusFromINTULocationStatus(INTULocationStatus status);
    
typedef void (^ENLocationCompletionBlock)(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status);
#define kENLocationMinimumInterval  20
#define kENLocationRequestTimeout   10

@interface ENLocationManager : NSObject
@property (nonatomic, assign) ENLocationStatus locationStatus;
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ENLocationManager)
- (void)getLocationWithCompletion:(ENLocationCompletionBlock)completion;

+ (INTULocationServicesState)locationServicesState;

+ (CLLocation *)cachedCurrentLocation;

+ (void)registerLocationDeniedHandler:(void(^)(void))handler;
+ (void)registerLocationDisabledHanlder:(void (^)(void))handler;

@end
