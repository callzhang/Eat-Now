//
//  ENServer.h
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#ifndef EatNow_ENServer_h
#define EatNow_ENServer_h
extern DDLogLevel const ddLogLevel;

typedef NS_OPTIONS(NSInteger, ENServerManagerStatus){
	DeterminReachability = 1 << 0,
	IsReachable = 1 << 1, //opposite of not reachable
	GettingLocation = 1 << 2,
	GotLocation = 1 << 3, //opposite of failed
	FetchingRestaurant = 1 << 4,
	FetchedRestaurant = 1 << 5 //opposite of failed
};

typedef NS_ENUM(NSUInteger, ENLocationStatus) {
    ENLocationStatusUnknown,
    ENLocationStatusGettingLocation,
    ENLocationStatusGotLocation,
	ENLocationStatusError
};

typedef NS_ENUM(NSUInteger, ENResturantDataStatus) {
    ENResturantDataStatusFetchingUnkown,
    ENResturantDataStatusFetchingRestaurant,
    ENResturantDataStatusFetchedRestaurant,
    ENResturantDataStatusError,
};



#endif
