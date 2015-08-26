//
//  GNMapOpener.m
//  GNMapOpenerExample
//
//  Created by Jakub Knejzlik on 09/04/15.
//  Copyright (c) 2015 Jakub Knejzlik. All rights reserved.
//

#import "GNMapOpener.h"

#import "GNAppleMapOpenerService.h"
#import "GNGoogleMapOpenerService.h"
#import "BlocksKit.h"

@interface GNMapOpener () /*<UIActionSheetDelegate>*/

@end

@implementation GNMapOpener
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static GNMapOpener *map = nil;
    dispatch_once(&onceToken, ^{
        map = [[GNMapOpener alloc] init];
    });
    
    return map;
}

-(void)openItem:(GNMapOpenerItem *)item presetingViewController:(UIViewController *)viewController{
    NSArray *services = [self availableServices];
    if (services.count == 1) {
        [self openItem:item withService:[services firstObject]];
    }
    else{
        NSMutableArray *titles = [NSMutableArray array];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Open in...", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            [viewController dismissViewControllerAnimated:YES completion:nil];
        }]];
        for (GNMapOpenerService *service in services) {
            [titles addObject:service.name];
            [alert addAction:[UIAlertAction actionWithTitle:service.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self openItem:item withService:service];
            }]];
        }
        
        [viewController presentViewController:alert animated:YES completion:nil];
    }
}
-(void)openItem:(GNMapOpenerItem *)item withService:(GNMapOpenerService *)service{
    [service openItem:item];
}

-(NSArray *)availableServices{
    NSMutableArray *array = [NSMutableArray array];
    
    if ([GNAppleMapOpenerService isAvailable]) {
        [array addObject:[[GNAppleMapOpenerService alloc] init]];
    }
    if ([GNGoogleMapOpenerService isAvailable]) {
        [array addObject:[[GNGoogleMapOpenerService alloc] init]];
    }
    
    return array;
}
//
//#pragma mark - Action Sheet Delegate methods
//
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
//    NSLog(@"%i",(int)buttonIndex);
//    if (actionSheet.cancelButtonIndex != buttonIndex) {
//        NSArray *services = [self availableServices];
//        [self openItems:<#(NSArray *)#> withService:<#(GNMapOpenerService *)#>]
//    }
//}

@end
