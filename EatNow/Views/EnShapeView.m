//
//  EnShapeView.m
//  EatNow
//
//  Created by Zitao Xiong on 5/9/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#import "EnShapeView.h"

@implementation EnShapeView
+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}
@end
