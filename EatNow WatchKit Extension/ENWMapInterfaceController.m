//
//  ENWMapInterfaceController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/1/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ENWMapInterfaceController.h"


@interface ENWMapInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceMap *interfaceMap;

@end


@implementation ENWMapInterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    // Configure interface objects here.
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
    CLLocationDegrees lat = 40.706556;
    CLLocationDegrees lon = -74.006911;
    CLLocationCoordinate2D coordinate2D = CLLocationCoordinate2DMake(lat, lon);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion regon = MKCoordinateRegionMake(coordinate2D, span);
    [self.interfaceMap setRegion:regon];
    
    [self.interfaceMap addAnnotation:coordinate2D withPinColor:WKInterfaceMapPinColorRed];
    [self.interfaceMap addAnnotation:CLLocationCoordinate2DMake(lat, -74.0099) withPinColor:WKInterfaceMapPinColorGreen];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

@end



