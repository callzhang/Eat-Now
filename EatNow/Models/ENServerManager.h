//
//  ENServerManager.h
//  EatNow
//
//  Created by Lei Zhang on 11/27/14.
//  Copyright (c) 2014 modocache. All rights reserved.
//

#define kMaxSelectedRestaurantRetainTime			3600
#define kServerUrl                  @"http://api.eatnow.cc"
#define kServerUrl2                  @"http://eat-now.herokuapp.com"

//#define kCuisineNames               @[@"Afghan", @"African", @"American", @"Asian", @"Australian", @"Bakery", @"Bars", @"Belgian", @"Brasseries", @"Brazilian", @"Breakfast", @"British", @"Buffets", @"Cafes", @"Cambodian", @"Caribbean", @"Central_European", @"Chinese", @"Coffee", @"Creperie", @"Cuban", @"Delis", @"Dessert", @"Eastern_European", @"Ethiopian", @"Fast_Food", @"Filipino", @"Food_Truck", @"French", @"German", @"Greek", @"Halal", @"Hawaiian", @"Healthy", @"Himalayan", @"Indian", @"Indonesian", @"Italian", @"Japanese", @"Korean", @"Kosher", @"Latin_American", @"Malaysian", @"Mediterranean", @"Mexican", @"Middle_Eastern", @"Modern", @"Mongolian", @"Moroccan", @"Night_Life", @"Northern_European", @"Pakistani", @"Persian", @"Polish", @"Russian", @"Seafood", @"South_American", @"Southern", @"Spanish", @"Steakhouses", @"Tea_Rooms", @"Thai", @"Turkish", @"Vegetarian", @"Vietnamese"]

#define kBasePreferences             @[@"African", @"American", @"Brazilian", @"Caribbean", @"Chinese", @"Cuban", @"French", @"German", @"Greek", @"Indian", @"Italian", @"Japanese", @"Korean", @"Latin_American", @"Malaysian", @"Mediterranean", @"Mexican", @"Middle_Eastern", @"Russian", @"Spanish", @"Thai", @"Turkish", @"Vietnamese"]
#define kBasePreferencesValue        @[@"African", @"American", @"Brazilian", @"Caribbean", @"Chinese", @"Cuban", @"French", @"German", @"Greek", @"Indian", @"Italian", @"Japanese", @"Korean", @"Latin American", @"Malaysian", @"Mediterranean", @"Mexican", @"Middle Eastern", @"Russian", @"Spanish", @"Thai", @"Turkish", @"Vietnamese"]

extern NSString * const kHistroyUpdated;
extern NSString * const kRatingUpdated;
extern NSString * const kPreferenceUpdated;
extern NSString * const kUserUpdated;
extern NSString * const kShouldShowNiceChoiceKey;
extern NSString * const kShouldShowTutorial;
extern NSString * const kBasePreferenceUpdated;

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "ENDefines.h"
#import "ENRestaurant.h"
#import "ENServer.h"
#import "GCDSingleton.h"

@class CLLocation;
@interface ENServerManager : NSObject
//@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, assign) ENResturantDataStatus fetchStatus;
@property (nonatomic, strong) ENRestaurant *selectedRestaurant;
@property (nonatomic, strong) NSDate *selectedTime;
@property (nonatomic, strong) NSString *selectionHistoryID;
/**
 *  keeps users LATEST rating for restaurants
 *  Example: {restaurant_id: {rating: 9, date: Mar 15, 2015}}
 */
@property (nonatomic, strong) NSMutableDictionary *userRating;
@property (nonatomic, strong) NSArray *history;
/**
 *
 */
@property (nonatomic, strong) NSDictionary *preference;
@property (nonatomic, strong) NSDictionary *basePreference;
@property (nonatomic, strong) NSDictionary *me;
@property (nonatomic, strong) NSString *myID;
@property (nonatomic, strong) NSNumber *session;

//We still need Singleton as it stores shared information
GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(ENServerManager)

//functions
- (void)getUserWithCompletion:(void (^)(NSDictionary *user, NSError *error))block;
- (void)searchRestaurantsAtLocation:(CLLocation *)location WithCompletion:(void (^)(BOOL success, NSError *error, NSArray *response))block;
- (void)updateRestaurant:(ENRestaurant *)restaurant withInfo:(NSDictionary *)dic completion:(void (^)(NSError *error))block;

#pragma mark - User actions
- (void)selectRestaurant:(ENRestaurant *)restaurant like:(float)value completion:(ErrorBlock)block;
- (void)cancelHistory:(NSString *)historyID completion:(ErrorBlock)block;
- (BOOL)canSelectNewRestaurant;
- (void)clearSelectedRestaurant;
- (void)updateHistory:(NSDictionary *)history withRating:(float)rate completion:(ErrorBlock)block;
- (void)updateBasePreference:(NSDictionary *)preference completion:(ErrorBlock)block;
@end
