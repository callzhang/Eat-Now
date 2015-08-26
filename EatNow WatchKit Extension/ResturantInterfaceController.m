//
//  ResturantInterfaceController.m
//  EatNow
//
//  Created by Zitao Xiong on 4/4/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "ResturantInterfaceController.h"
#import "ENRestaurant.h"
#import "AFNetworking.h"
#import "ENMapManager.h"
#import "WatchKitAction.h"


@interface ResturantInterfaceController()
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantName;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantCategory;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantDistance;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *restaurantPrice;
@property (nonatomic, strong) ENRestaurant *restaurant;
@property (weak, nonatomic) IBOutlet WKInterfaceGroup *actionButtonGroup;
@property (weak, nonatomic) IBOutlet WKInterfaceButton *actionButton;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *openTil;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *ratingLabel;
@property (nonatomic, strong) ENMapManager *mapManager;
@end


@implementation ResturantInterfaceController

- (void)awakeWithContext:(ENRestaurant *)context {
    [super awakeWithContext:context];
    self.restaurant = context;
    NSLog(@"load restaurant:%@", context);
    self.mapManager = [[ENMapManager alloc] init];
    
    [self.mapManager estimatedWalkingTimeToLocation:self.restaurant.location
                                         completion:^(MKRoute *route, NSError *error) {
                                             NSString *transportType = @"";
                                             switch (route.transportType) {
                                                 case MKDirectionsTransportTypeAutomobile:
                                                     transportType = @"driving";
                                                     break;
                                                 case MKDirectionsTransportTypeWalking:
                                                     transportType = @"walking";
                                                     break;
                                                 default:
                                                     break;
                                             }
                                             self.restaurantDistance.text = [NSString stringWithFormat:@"%.1f mins %@", route.expectedTravelTime / 60.0, transportType];
                                         }];
    
    
    self.restaurantName.text = context.name;
    self.restaurantCategory.text = context.cuisineText;
    self.restaurantPrice.text = [context.price valueForKey:@"currency"];
    self.openTil.text = context.openInfo;
    self.ratingLabel.text = [NSString stringWithFormat:@"%.1f", context.rating.floatValue];
    self.restaurantDistance.text = [NSString stringWithFormat:@"%@", @(context.distance.floatValue/1000)];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSURL *url = [NSURL URLWithString:self.restaurant.imageUrls.firstObject];
//        NSData *data = [NSData dataWithContentsOfURL:url];
//        UIImage *placeholder = [UIImage imageWithData:data];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.actionButtonGroup setBackgroundImage:placeholder];
//        });
//    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        WatchKitAction *action = [WatchKitAction new];
        action.type = ENWatchKitActionTypeImageDownload;
        action.url = self.restaurant.imageUrls.firstObject;
        
        [[self class] openParentApplication:action.toDictionary reply:^(NSDictionary *replyInfo, NSError *error) {
            if (error) {
                NSLog(@"open parentapplication error:%@", error);
                return ;
            }
            
//            NSLog(@"got reply, error: %@, %@", replyInfo, error);
            NSError *jsonError;
            WatchKitResponse *response = [[WatchKitResponse alloc] initWithDictionary:replyInfo error:&jsonError];
            if (jsonError) {
                NSLog(@"encode error:%@", jsonError);
                return ;
            }
            
            self.restaurant.appleWatchImage = response.image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.self.actionButtonGroup setBackgroundImage:response.image];
            });
        }];
    });
    
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (id)contextForSegueWithIdentifier:(NSString *)segueIdentifier {
    if ([segueIdentifier isEqualToString:@"toRestaurantDetail"]) {
        return self.restaurant;
    }
    
    return self.restaurant;
}

#pragma mark -
- (NSString *)stringFromArray:(NSArray *)array{
    NSMutableString *string = [NSMutableString stringWithString:@""];
    for (NSString *key in array) {
        [string appendFormat:@"%@, ", key];
    }
    return [string substringToIndex:string.length-2];
}

//not used
- (void)downloadImageWithURL:(NSString *)url completionHanlder:(void (^)(UIImage *iamge))handler{
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *downloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    // Step 4: set handling for answer from server and errors with request
    [downloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        // here we must create NSData object with received data...
        NSData *data = [[NSData alloc] initWithData:responseObject];
        UIImage *image = [[UIImage alloc] initWithData:data];
        if (handler) {
            handler(image);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"file downloading error : %@", [error localizedDescription]);
        if (handler) {
            handler(nil);
        }
    }];
    
    // Step 5: begin asynchronous download
    [downloadRequest start];
}
@end



