//
//  GNAppleMapOpenerService.m
//  GNMapOpenerExample
//
//  Created by Jakub Knejzlik on 09/04/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import "GNAppleMapOpenerService.h"

#import <MapKit/MapKit.h>

@implementation GNAppleMapOpenerService

-(NSString *)name{
    return NSLocalizedString(@"Apple maps", nil);
}

+(BOOL)isAvailable{
    return YES;
}

-(void)openItem:(GNMapOpenerItem *)item{
    Class itemClass = [MKMapItem class];
    if (itemClass && [itemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)]) {
        MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate:item.coordinate addressDictionary: nil];
        MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark:place];
        destination.name = item.name;
        NSDictionary* options = nil;
        switch (item.directionsType) {
            case GNMapOpenerDirectionsTypeCar:
                options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
                break;
            case GNMapOpenerDirectionsTypeWalk:
                options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeWalking};
            default:
                break;
        }
        [MKMapItem openMapsWithItems:@[destination] launchOptions: options];
    } else {
        CLLocationCoordinate2D coordinate = item.coordinate;
        NSString* url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",coordinate.latitude, coordinate.longitude,coordinate.latitude,coordinate.longitude];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

@end
