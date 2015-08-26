//
//  ENLocationManager.m
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENLocationManager.h"
#import "FBKVOController.h"
#import "extobjc.h"
#import "NSTimer+BlocksKit.h"
#import "Mixpanel.h"
ENLocationStatus enLocationStatusFromINTULocationStatus(INTULocationStatus status) {
    if (status == INTULocationStatusSuccess) {
        return ENLocationStatusGotLocation;
    }
    else if (status == INTULocationStatusTimedOut){
        return ENLocationStatusGotLocation;
    }
    else if (status == INTULocationStatusServicesDisabled){
        return ENLocationStatusError;
    }
    else if (status == INTULocationStatusServicesDenied || status == INTULocationStatusServicesRestricted){
        return ENLocationStatusError;
    }
    else if (status == INTULocationStatusError){
        return ENLocationStatusError;
    }
    else{
        return ENLocationStatusUnknown;
    }
}

static CLLocation *_cachedLocation = nil;
static void (^_locationDisabledHanlder)(void) = nil;
static void (^_locationDeniedHanlder)(void) = nil;

@interface ENLocationManager()<CLLocationManagerDelegate>
@property (nonatomic, strong) INTULocationManager *locationManager;
@property (nonatomic, strong) NSDate *requestTime;
@end

@implementation ENLocationManager
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(ENLocationManager)
- (instancetype)init{
    self = [super init];
    if (self) {
        self.locationManager = [INTULocationManager sharedInstance];
    }
    return self;
}

+ (INTULocationServicesState)locationServicesState{
    return [INTULocationManager locationServicesState];
}

- (void)getLocationWithCompletion:(ENLocationCompletionBlock)completion {
	//status
	self.locationStatus = ENLocationStatusGettingLocation;
    DDLogVerbose(@"Getting location");
    self.requestTime = [NSDate date];
    [[Mixpanel sharedInstance] timeEvent:@"get location"];
    
	//request
    @weakify(self);
    
    [[self class] setCachedCurrentLocation:nil];
    
    [[INTULocationManager sharedInstance] requestLocationWithDesiredAccuracy:INTULocationAccuracyBlock timeout:kENLocationRequestTimeout delayUntilAuthorized:YES block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
        @strongify(self);
        if (currentLocation) {
            [[Mixpanel sharedInstance] track:@"got location"];
            DDLogInfo(@"It took %.0fs to get location", [[NSDate date] timeIntervalSinceDate:self.requestTime]);
        }
        
        [[self class] setCachedCurrentLocation:currentLocation];
        
        if (status == INTULocationStatusServicesDenied) {
            if (_locationDeniedHanlder) {
                _locationDeniedHanlder();
            }
        }
        else if (status == INTULocationStatusServicesDisabled) {
            if (_locationDisabledHanlder) {
                _locationDisabledHanlder();
            }
        }
        
        if (completion) {
            completion(currentLocation, achievedAccuracy, status);
        }
    }];
}

+ (CLLocation *)cachedCurrentLocation {
    return _cachedLocation;
}

+ (void)setCachedCurrentLocation:(CLLocation *)location {
    _cachedLocation = location;
}

+ (void)registerLocationDeniedHandler:(void (^)(void))handler {
    _locationDeniedHanlder = handler;
}

+ (void)registerLocationDisabledHanlder:(void (^)(void))handler {
    _locationDisabledHanlder = handler;
}
@end
