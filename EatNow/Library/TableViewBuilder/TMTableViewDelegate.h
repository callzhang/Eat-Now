//
//  TMTableViewDelegate.h
//
//  Created by Zitao Xiong on 4/8/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TMTableViewBuilder;
@interface TMTableViewDelegate : NSObject<UITableViewDelegate>
@property (nonatomic, weak) NSObject<UITableViewDelegate>* delegate;
- (instancetype)initWithTableViewBuilder:(TMTableViewBuilder *)tableViewBuilder;
@end
