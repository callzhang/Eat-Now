//
//  JSONValueTransformer+UIImage.h
//  VideoGuide
//
//  Created by Zitao Xiong on 3/20/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "JSONValueTransformer.h"

@interface JSONValueTransformer (UIImage)
- (id)UIImageFromNSString:(NSString *)string;
- (id)JSONObjectFromUIImage:(UIImage *)image;
@end
