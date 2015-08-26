//
//  ENUtil.h
//  EatNow
//
//  Created by Lee on 2/13/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ENDefines.h"
#import "JGProgressHUD.h"
typedef enum{
    hudStyleSuccess,
    hudStyleFailed,
    hudStyleWarning,
    HUDStyleInfo,
    HUDStyleNiceChioce
}HUDStyle;
#define kUUID                           @"UUID"
#define TICK                            NSDate *startTime = [NSDate date];
#define TICK2                           startTime = [NSDate date];
#define TOCK                            NSLog(@"Time: %f", -[startTime timeIntervalSinceNow]);


//
//#define UIColorFromRGB(rgbValue) \
//    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
//    green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
//    blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
//    alpha:1.0]

extern DDLogLevel const ddLogLevel;
void ENLogError(NSString *fmt, ...);

@interface ENUtil : UIView
+ (instancetype)shared;
+ (void)initLogging;
+ (NSString *)myUUID;
+ (NSString *)generateUUID;
+ (NSDate *)string2date:(NSString *)string;

//time
+ (NSString *)getStringFromTimeInterval:(NSTimeInterval)time;
+ (UIColor *)colorFromHexString:(NSString *)hexString;

//HUD
@property (nonatomic, strong) NSMutableArray *HUDs;
+ (JGProgressHUD *)showWatingHUB;
+ (JGProgressHUD *)showText:(NSString *)string;
+ (JGProgressHUD *)showSuccessHUBWithString:(NSString *)string;
+ (JGProgressHUD *)showFailureHUBWithString:(NSString *)string;
+ (JGProgressHUD *)showWarningHUBWithString:(NSString *)string;
+ (JGProgressHUD *)showNiceChoice:(NSString *)string;
+ (void)dismissHUD;
+ (UIView *)topView;
+ (UIViewController *)topViewController;

@end

@interface UIView(HUD)
- (JGProgressHUD *)showNotification:(NSString *)alert WithStyle:(HUDStyle)style audoHide:(float)timeout;
- (JGProgressHUD *)showSuccessNotification:(NSString *)alert;
- (JGProgressHUD *)showFailureNotification:(NSString *)alert;
- (JGProgressHUD *)showLoopingWithTimeout:(float)timeout;
- (void)dismissHUD;
@end

@interface NSArray(Extend)
- (NSString *)string;
@end

@interface UIImage (Blur)
- (UIImage *)bluredImage;
@end

CGFloat ENExpectedLabelHeight(UILabel *label, CGFloat width);