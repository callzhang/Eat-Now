//
//  GNMapOpenerOptions.h
//  GNMapOpenerExample
//
//  Created by Jakub Knejzlik on 09/04/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

typedef NS_ENUM(NSUInteger, GNMapOpenerDirectionsType) {
    GNMapOpenerDirectionsTypeNone,
    GNMapOpenerDirectionsTypeTransit,
    GNMapOpenerDirectionsTypeCar,
    GNMapOpenerDirectionsTypeWalk
};


@interface GNMapOpenerItem : NSObject
@property (nonatomic) GNMapOpenerDirectionsType directionsType;
@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic,strong) NSString *name;

-(instancetype)initWithLocation:(CLLocation *)location;

@end
