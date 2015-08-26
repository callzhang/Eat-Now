//
//  JSONValueTransformer+UIImage.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/20/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "JSONValueTransformer+UIImage.h"

@implementation JSONValueTransformer (UIImage)
- (id)UIImageFromNSString:(NSString *)string {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:string options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image = [[UIImage alloc] initWithData:data];
    return image;
}

- (id)JSONObjectFromUIImage:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    NSString *base64 = [data base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    return base64;
}
@end
