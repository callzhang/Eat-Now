
//
//  ENServerManager.m
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#import "ENServerManager.h"
#import <AFNetworking/AFNetworking.h>
#import "ENRestaurant.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "FBKVOController.h"
#import "ENLocationManager.h"
#import "ENUtil.h"
#import "NSDate+Extension.h"
#import "NSDate+MTDates.h"
#import "Mixpanel.h"

NSString * const kHistroyUpdated = @"history_updated";
NSString * const kRatingUpdated = @"rating_updated";
NSString * const kPreferenceUpdated = @"preference_updated";
NSString * const kUserUpdated = @"user_updated";
NSString * const kShouldShowNiceChoiceKey = @"shouldShowNiceChoice";
NSString * const kShouldShowTutorial = @"shouldShowTutorial";
NSString * const kBasePreferenceUpdated = @"basePreferenceUpdated";

@import CoreLocation;

@interface ENServerManager()<CLLocationManagerDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachability;
@property (nonatomic, strong) NSMutableArray *searchCompletionBlocks;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, readonly) NSDictionary *emptyBasePreference;
@end


FBTweakAction(@"Algorithm", @"Clean", @"ID", ^{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUUID];
    [[ENServerManager shared] searchRestaurantsAtLocation:[[CLLocation alloc] initWithLatitude:40 longitude:-70] WithCompletion:nil];
    DDLogInfo(@"Removed user ID");
});



@implementation ENServerManager
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(ENServerManager)

- (ENServerManager *)init{
    self = [super init];
    if (self) {
        
        //_restaurants = [NSMutableArray new];
        _searchCompletionBlocks = [NSMutableArray new];
        
        //indicator
        [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
		
		//manager
		//_requestManager = [AFHTTPRequestOperationManager manager];
        
        //defaults
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{kShouldShowNiceChoiceKey: @YES,
                                                                  kShouldShowTutorial: @YES}];
    }
    return self;
}

#pragma mark - Main method
//TODO: need to cancel previous operation when multiple requests happens
- (void)searchRestaurantsAtLocation:(CLLocation *)currenLocation WithCompletion:(void (^)(BOOL success, NSError *error, NSArray *response))block{
    //add to completion block
    self.session = @(self.session.unsignedIntegerValue +1);
    [[Mixpanel sharedInstance].people increment:@"session" by:@1];
    self.lastLocation = currenLocation;
    if (block) [self.searchCompletionBlocks addObject:block];
    
    if (self.fetchStatus == ENResturantDataStatusFetchingRestaurant) {
        DDLogInfo(@"Already requesting restaurant.");
        return;
    }
    [[Mixpanel sharedInstance] timeEvent:@"Search restaurant"];
    self.fetchStatus = ENResturantDataStatusFetchingRestaurant;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSString *myID = [[self class] myUUID];
    NSDictionary *dic = @{@"username":myID,
                          @"latitude":@(currenLocation.coordinate.latitude),
                          @"longitude":@(currenLocation.coordinate.longitude),
						  @"time": [NSDate date].ISO8601
                          //@"radius":@500
                          };
    DDLogInfo(@"Request restaurant: %@", dic);
    NSString *path = [NSString stringWithFormat:@"%@/%@", kServerUrl, @"search"];
    [manager GET:path parameters:dic
          success:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
              DDLogVerbose(@"GET restaurant list %ld", (unsigned long)responseObject.count);
              //mix panel
              [[Mixpanel sharedInstance] track:@"Search restaurant" properties:@{@"location": @{@"latitude": @(currenLocation.coordinate.latitude),
                                                                                                @"longitude": @(currenLocation.coordinate.longitude)},
                                                                                 @"latitude": @(currenLocation.coordinate.latitude),
                                                                                 @"longitude": @(currenLocation.coordinate.longitude),
                                                                                 @"success": @YES}];
              
              //process data
              NSMutableArray *mutableResturants = [NSMutableArray array];
              for (NSDictionary *restaurant_json in responseObject) {
				  ENRestaurant *restaurant = [[ENRestaurant alloc] initRestaurantWithDictionary:restaurant_json];
                  if (restaurant) {
                      [mutableResturants addObject:restaurant];
				  }else{
					  DDLogError(@"Invalid restaurant data: %@", restaurant_json);
				  }
              }
              
              //server returned sorted from high to low
              [mutableResturants sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"score" ascending:NO]]];
              
              //completion
              for (id completion in self.searchCompletionBlocks) {
                  void (^cachedCompletion)(BOOL, NSError*, NSArray*) = completion;
                  cachedCompletion(YES, nil, mutableResturants.copy);
              }
              [self.searchCompletionBlocks removeAllObjects];
              
              //change status
              self.fetchStatus = ENResturantDataStatusFetchedRestaurant;
              
          }failure:^(AFHTTPRequestOperation *operation,NSError *error) {
              
              NSString *str = [NSString stringWithFormat:@"Failed to get restaurant list with Error: %@", error];
              DDLogError(@"%@", str);
              //mix panel
              [[Mixpanel sharedInstance] track:@"Search restaurant"];
              
              for (id completion in self.searchCompletionBlocks) {
                  void (^cachedCompletion)(BOOL, NSError*, NSArray*) = completion;
                  cachedCompletion(NO, error, nil);
              }
              
              [self.searchCompletionBlocks removeAllObjects];
              
              self.fetchStatus = ENResturantDataStatusError;
          }];
}

- (void)getUserWithCompletion:(void (^)(NSDictionary *user, NSError *error))block{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[Mixpanel sharedInstance] timeEvent:@"Get user"];
    NSString *url = [NSString stringWithFormat:@"%@/user/%@",kServerUrl, self.myID];
    DDLogInfo(@"Requesting user: %@", url);
    [manager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, NSDictionary *user) {
		NSParameterAssert([user isKindOfClass:[NSDictionary class]]);
        [[Mixpanel sharedInstance] track:@"Get user"];
        //more data logics are embedded in user setter
		self.me = user;
        
        //return
        if (block) {
            block(user, nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[Mixpanel sharedInstance] track:@"Get user"];

        NSString *s = [NSString stringWithFormat:@"Failed to get user: %@", error.localizedDescription];
        DDLogError(s);
        if (block) {
            block(nil, error);
        }
    }];
}

- (void)updateRestaurant:(ENRestaurant *)restaurant withInfo:(NSDictionary *)dic completion:(void (^)(NSError *))block{
    NSParameterAssert(restaurant);
    NSParameterAssert([dic.allKeys containsObject:@"img_url"]);
    NSArray *images = dic[@"img_url"];
    NSParameterAssert([images isKindOfClass:[NSArray class]]);
    NSParameterAssert(images.count > 1);
    [[Mixpanel sharedInstance] timeEvent:@"Update restaurant"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    NSString *url = [NSString stringWithFormat:@"%@/restaurant/%@",kServerUrl, restaurant.ID];
    [manager PUT:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[Mixpanel sharedInstance] track:@"Update restaurant"];
        
        if(block) block(nil);
        DDLogVerbose(@"Updated restaurant (%@) images of count %@", restaurant.name, @(images.count));
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        if(block) block(error);
        DDLogError(@"Failed to update restaurant: %@", error.localizedDescription);
    }];
}

#pragma mark - User actions
- (void)selectRestaurant:(ENRestaurant *)restaurant like:(float)value completion:(void (^)(NSError *error))block{
	NSParameterAssert(!self.selectedRestaurant);
    NSParameterAssert(value > 0);
    self.selectedRestaurant = restaurant;
    self.selectedTime = [NSDate date];
    
    [[Mixpanel sharedInstance] timeEvent:@"Select restaurant"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *dic = @{@"username": self.myID,
						  @"restaurantId": restaurant.ID,
						  @"like": @(value),
						  @"date": [NSDate date].ISO8601,
                          @"location": @{@"latitude": @([ENLocationManager cachedCurrentLocation].coordinate.latitude),
                                         @"longitude": @([ENLocationManager cachedCurrentLocation].coordinate.longitude),
                                         @"distance": restaurant.distance}
                          };
						  
    DDLogVerbose(@"Select restaurant: %@", dic);
    NSString *path = [NSString stringWithFormat:@"%@/%@", kServerUrl, @"select"];
    [manager POST:path parameters:dic success:^(AFHTTPRequestOperation *operation, NSDictionary *history) {
        [[Mixpanel sharedInstance] track:@"Select restaurant" properties:@{@"restaurant": restaurant.ID,
                                                                           @"latitude": @([ENLocationManager cachedCurrentLocation].coordinate.latitude),
                                                                           @"longitude": @([ENLocationManager cachedCurrentLocation].coordinate.longitude)}];
        self.selectionHistoryID = history[@"_id"];
        self.selectedTime = [NSDate date];
        self.selectedRestaurant = restaurant;
        
        if (block) block(nil);
        
        //reload
        [self getUserWithCompletion:nil];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[Mixpanel sharedInstance] track:@"Select restaurant" properties:@{@"restaurant": restaurant.ID,
                                                                           @"latitude": @([ENLocationManager cachedCurrentLocation].coordinate.latitude),
                                                                           @"longitude": @([ENLocationManager cachedCurrentLocation].coordinate.longitude)}];
        block(error);
        NSString *s = [NSString stringWithFormat:@"%@", error];
        DDLogError(s);
    }];
}

- (void)cancelHistory:(NSString *)historyID completion:(ErrorBlock)block{
    NSParameterAssert(historyID);
    [[Mixpanel sharedInstance] timeEvent:@"Cancel history"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *path = [NSString stringWithFormat:@"%@/user/%@/history/%@", kServerUrl, [ENServerManager myUUID], historyID];
    [manager DELETE:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [[Mixpanel sharedInstance] track:@"Cancel history" properties:@{@"history": historyID, @"success": @YES}];
        
        [self getUserWithCompletion:nil];
        [self clearSelectedRestaurant];
        if (block) block(nil);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[Mixpanel sharedInstance] track:@"Cancel history" properties:@{@"history": historyID, @"success": @NO}];
        if (block) block(error);
        DDLogError(@"Failed to cancel history(%@): %@", historyID, error.localizedDescription);
    }];
}

- (BOOL)canSelectNewRestaurant{
	if (self.selectedRestaurant) {
		if ([[NSDate date] timeIntervalSinceDate:self.selectedTime] < kMaxSelectedRestaurantRetainTime) {
			return NO;
		}
		else{
			[self clearSelectedRestaurant];
		}
	}
	return YES;
}

- (void)clearSelectedRestaurant{
	self.selectedRestaurant = nil;
	self.selectedTime = nil;
}

- (void)updateHistory:(NSDictionary *)history withRating:(float)rate completion:(ErrorBlock)block {
    NSString *historyID = history[@"_id"];
    ENRestaurant *restaurant = [[ENRestaurant alloc] initRestaurantWithDictionary:history[@"restaurant"]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [[Mixpanel sharedInstance] timeEvent:@"Update rating"];
    
    NSParameterAssert(rate>= 1 && rate <= 5);
    
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/history/%@",kServerUrl, self.myID, historyID];
    [manager PUT:url parameters:@{@"like": @(rate - 3)} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(block) block(nil);
        
        [[Mixpanel sharedInstance] track:@"Update rating"
                              properties:@{@"history": historyID,
                                           @"restaurant": restaurant.ID,
                                           @"rating": @(rate),
                                           @"success": @YES}];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[Mixpanel sharedInstance] track:@"Update rating"
                              properties:@{@"history": historyID,
                                           @"restaurant": restaurant.ID,
                                           @"rating": @(rate),
                                           @"success": @NO}];
        if(block) block(error);
        DDLogError(@"Failed to update history: %@", error.localizedDescription);
    }];
}

#pragma mark - Data processing
- (void)setMe:(NSDictionary *)me{
    NSParameterAssert([me valueForKey:@"all_history"]);
    NSParameterAssert([me valueForKey:@"preference"]);
    NSParameterAssert([me valueForKey:@"username"]);
    NSDictionary *basePreference = [me valueForKey:@"basePrefrence"];
    
    _me = me;
    self.preference = [_me valueForKey:@"preference"];
    self.basePreference = basePreference ?: self.emptyBasePreference;
    self.history = [_me valueForKeyPath:@"all_history"];
    if ([me valueForKey:@"base_preference"]) {
        NSDictionary *base = [me valueForKey:@"base_preference"];
        self.basePreference = base;
    }
    [self setUserRatingWithData:[_me valueForKeyPath:@"all_history"]];
}

- (void)setHistory:(NSArray *)history{
    //generate restaurant
    _history = history;
    
    //update selected
    NSDate *latestSelected = [NSDate dateWithTimeIntervalSince1970:0];
    ENRestaurant *latestRestaurant;
    NSString *latestHistoryID;
    
    for (NSDictionary *historyData in history) {
        NSString *dateStr = historyData[@"date"];
        NSDate *date = [NSDate dateFromISO1861:dateStr];
        
        //update selected restaurant
        if ([latestSelected compare:date] == NSOrderedAscending && [[NSDate date] timeIntervalSinceDate:date] < kMaxSelectedRestaurantRetainTime) {
            NSDictionary *data = historyData[@"restaurant"];
            ENRestaurant *restaurant = [[ENRestaurant alloc] initRestaurantWithDictionary:data];
            if (!restaurant) continue;
            latestSelected = date;
            latestRestaurant = restaurant;
            latestHistoryID = historyData[@"_id"];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kHistroyUpdated object:nil];
    
    //resume selected item if none
    if (!_selectedRestaurant && latestHistoryID) {
        self.selectedTime = latestSelected;
        self.selectedRestaurant = latestRestaurant;
        self.selectionHistoryID = latestHistoryID;
        //TODO: post notification
    }
}

- (void)setUserRatingWithData:(NSArray *)history{
    //parse history rating
    self.userRating = [NSMutableDictionary new];
    for (NSDictionary *historyData in history) {
        NSString *dateStr = historyData[@"date"];
        NSDate *date = [NSDate dateFromISO1861:dateStr];
        if (!date) {
            DDLogWarn(@"Date string not expected %@", dateStr);
            continue;
        }
        NSNumber *rate = historyData[@"like"]?:@0;
        NSNumber *reviewed = historyData[@"reviewed"]?:@0;
        NSDictionary *restaurantData = historyData[@"restaurant"];
        ENRestaurant *restaurant = [[ENRestaurant alloc] initRestaurantWithDictionary:restaurantData];
        NSString *ID = restaurant.ID;
        
        //keep unique rating for each restaurant
        NSDictionary *ratingDic = self.userRating[ID];
        @try {
            if (ratingDic.allKeys.count == 0) {
                _userRating[ID] = @{@"rating": rate, @"time":date, @"reviewed":reviewed};
            }else{
                NSDate *prevTime = ratingDic[@"time"];
                if ([prevTime compare:date] == NSOrderedAscending) {
                    //date is later
                    _userRating[ID] = @{@"rating": rate, @"time":date, @"reviewed":reviewed};
                }
            }
        }
        @catch (NSException *exception) {
            DDLogError(@"Failed to assign history %@ \n%@", historyData, exception);
        }
        
    }
    
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kRatingUpdated object:nil];
}

- (void)setPreference:(NSDictionary *)preference{
    NSParameterAssert([preference isKindOfClass:[NSDictionary class]]);
    //NSParameterAssert(preference.allKeys.count == kCuisineNames.count);
    _preference = preference;
    [[NSNotificationCenter defaultCenter] postNotificationName:kPreferenceUpdated object:preference];
}

- (void)updateBasePreference:(NSDictionary *)preference completion:(ErrorBlock)block{
    self.basePreference = preference;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *url = [NSString stringWithFormat:@"%@/user/%@/basePreference",kServerUrl, self.myID];
    [manager PUT:url parameters:preference success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *user = (NSDictionary *)responseObject;
        DDLogVerbose(@"Updaged user base preference: %@", [user objectForKey:@"base_preference"]);
        if (block) block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"Failed to update base preference: %@", error);
        if (block) block(error);
    }];
    
}

#pragma mark - Tools
- (NSString *)myID{
    return [ENServerManager myUUID];
}

+ (NSString *)myUUID{
    NSString *myID = [[NSUserDefaults standardUserDefaults] objectForKey:kUUID];
    if (!myID) {
        myID = [self generateUUID];
        DDLogInfo(@"ID %@ created", myID);
        [[NSUserDefaults standardUserDefaults] setObject:myID forKey:kUUID];
        [[Mixpanel sharedInstance] identify:myID];
        [[Mixpanel sharedInstance].people set:@{@"createdAt": [NSDate date]}];
    }
    [[Mixpanel sharedInstance] identify:myID];
    [[Mixpanel sharedInstance].people set:@{@"lastSeen": [NSDate date]}];
    return myID;
}

+ (NSString *)generateUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (NSNumber *)session{
    NSNumber *mySession = [[NSUserDefaults standardUserDefaults] objectForKey:@"session"];
    if (!mySession) {
        mySession = @0;
        [[NSUserDefaults standardUserDefaults] setValue:mySession forKey:@"session"];
    }
    return mySession;
}

- (void)setSession:(NSNumber *)session{
    [[NSUserDefaults standardUserDefaults] setValue:session forKey:@"session"];
}

- (NSDictionary *)emptyBasePreference{
    NSMutableDictionary *base = [NSMutableDictionary new];
    for (NSString *cuisine in kBasePreferences) {
        base[cuisine] = @0;
    }
    return base.copy;
}
@end

