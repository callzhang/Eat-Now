//
//  TMTextFieldRowItem.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMTextFieldRowItem.h"
#import "FBKVOController.h"
#import "extobjc.h"
#import "FBKVOController+Binding.h"
@interface TMTextFieldRowItem()
@end

@implementation TMTextFieldRowItem
#pragma mark -
+ (NSString *)reuseIdentifier {
   return @"TMTextFieldTableViewCell";
}
@end
