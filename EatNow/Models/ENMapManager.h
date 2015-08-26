//
//  ENMapManager.h
//  Pods
//
//  Created by Lee on 4/14/15.
//
//

#import <Foundation/Foundation.h>
#import "ENRestaurant.h"

typedef void (^ENRestaurantDirection)(MKRoute *route, NSError *error);

@import MapKit;
@interface ENMapManager : NSObject<MKMapViewDelegate>
@property (nonatomic, weak) MKMapView *map;

- (instancetype)initWithMap:(MKMapView *)map;

- (void)findDirectionsTo:(CLLocation *)location completion:(void (^)(MKDirectionsResponse *response, NSError *error))block;

- (void)findDirectionsFrom:(MKMapItem *)source to:(MKMapItem *)destination completion:(void (^)(MKDirectionsResponse *response, NSError *error))block;

- (void)estimatedWalkingTimeToLocation:(CLLocation *)location completion:(ENRestaurantDirection)block;

#pragma mark - Map routing
- (void)routeToRestaurant:(ENRestaurant *)restaurant repeat:(NSTimeInterval)updateInterval completion:(void (^)(NSTimeInterval length, NSError *error))block;

- (void)addAnnotationForRestaurant:(ENRestaurant *)restaurant;

- (void)cancelRouting;
@end
