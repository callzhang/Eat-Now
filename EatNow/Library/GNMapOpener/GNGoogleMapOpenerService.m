//
//  GNGoogleMapOpenerService.m
//  GNMapOpenerExample
//
//  Created by Jakub Knejzlik on 09/04/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import "GNGoogleMapOpenerService.h"

#import <OpenInGoogleMapsController.h>

@implementation GNGoogleMapOpenerService

-(NSString *)name{
    return NSLocalizedString(@"Google maps", nil);
}
+(BOOL)isAvailable{
    return [[OpenInGoogleMapsController sharedInstance] isGoogleMapsInstalled];
}
-(void)openItem:(GNMapOpenerItem *)item{
    if (item.directionsType == GNMapOpenerDirectionsTypeNone) {
        GoogleMapDefinition *mapDefinition = [[GoogleMapDefinition alloc] init];
        mapDefinition.center = item.coordinate;
        [[OpenInGoogleMapsController sharedInstance] openMap:mapDefinition];
    }else{
        GoogleDirectionsDefinition *definition = [[GoogleDirectionsDefinition alloc] init];
        switch (item.directionsType) {
            case GNMapOpenerDirectionsTypeCar:
                definition.travelMode = kGoogleMapsTravelModeDriving;
                break;
            case GNMapOpenerDirectionsTypeTransit:
                definition.travelMode = kGoogleMapsTravelModeTransit;
                break;
            case GNMapOpenerDirectionsTypeWalk:
                definition.travelMode = kGoogleMapsTravelModeWalking;
                break;
            default:
                break;
        }
        definition.destinationPoint = [GoogleDirectionsWaypoint waypointWithLocation:item.coordinate];
        [[OpenInGoogleMapsController sharedInstance] openDirections:definition];
    }
}
@end
