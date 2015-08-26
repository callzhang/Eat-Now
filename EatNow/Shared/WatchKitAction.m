//
//  WatchKitAction.m
//  EatNow
//
//  Created by Zitao Xiong on 4/26/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "WatchKitAction.h"
#import "AFNetworking.h"
#import "UIImage+Resizing.h"

@implementation WatchKitAction
- (void)performActionForApplication:(UIApplication *)application withCompletionHandler:(void (^)(WatchKitResponse *))handler {

        NSLog(@"background start");
        NSURL *URL = [NSURL URLWithString:self.url];
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        // Step 3: create AFHTTPRequestOperation object with our request
        AFHTTPRequestOperation *downloadRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        // Step 4: set handling for answer from server and errors with request
        [downloadRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            // here we must create NSData object with received data...
            NSData *data = [[NSData alloc] initWithData:responseObject];
            UIImage *image = [[UIImage alloc] initWithData:data];
            image = [image scaleToCoverSize:CGSizeMake(200, 200)];
            WatchKitResponse *response = [[WatchKitResponse alloc] init];
            response.image = image;
            if (handler) {
                handler(response);
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

@implementation WatchKitResponse

@end
