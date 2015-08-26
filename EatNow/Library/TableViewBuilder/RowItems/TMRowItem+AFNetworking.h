//
//  TMRowItem+AFNetworking.h
//  WaiJiaoLaiLe
//
//  Created by Zitao Xiong on 4/14/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

#import "TMRowItem.h"
@protocol AFURLResponseSerialization, TMImageCache;
@interface TMRowItem (AFNetworking)
@property (nonatomic, strong) id <AFURLResponseSerialization> imageResponseSerializer;
- (void)setImageWithURL:(NSURL *)url toKeyPath:(NSString *)keypath;
- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage toKeyPath:(NSString *)keypath;

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                     toKeyPath:(NSString *)keypath
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

+ (id <TMImageCache>)sharedImageCache;
+ (void)setSharedImageCache:(id <TMImageCache>)imageCache;
- (void)cancelImageRequestOperation;
@end

@protocol TMImageCache <NSObject>
- (UIImage *)cachedImageForRequest:(NSURLRequest *)request;
- (void)cacheImage:(UIImage *)image
        forRequest:(NSURLRequest *)request;
@end