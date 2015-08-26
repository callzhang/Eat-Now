//
//  WatchKitAction.h
//  EatNow
//
//  Created by Zitao Xiong on 4/26/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

typedef NS_ENUM(NSUInteger, ENWatchKitActionType) {
    ENWatchKitActionTypeImageDownload,
};


@class WatchKitResponse;
@interface WatchKitAction : JSONModel
@property (nonatomic, assign) ENWatchKitActionType type;
@property (nonatomic, strong) NSString<Optional> *url;

- (void)performActionForApplication:(UIApplication *)application withCompletionHandler:(void (^)(WatchKitResponse *))handler;
@end

//@interface WatchKitImageAction : WatchKitAction
//@property (nonatomic, strong) NSString *action;
//@end

@interface WatchKitResponse : JSONModel
@property (nonatomic, strong) UIImage<Optional> *image;
@end

//@interface WatchKitImageResponse : WatchKitResponse
//@property (nonatomic, strong) UIImage *image;
//@end