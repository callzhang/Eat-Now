//
//  TMTableViewDataSource.h
//  VideoGuide
//
//  Created by Zitao Xiong on 4/1/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TMTableViewDataSource;
@class TMTableViewBuilder;
@interface TMTableViewDataSource : NSObject<UITableViewDataSource>
@property (nonatomic, readonly, weak) TMTableViewBuilder *tableViewBuilder;
@property (nonatomic, weak) NSObject<TMTableViewDataSource> *dataSource;
- (instancetype)initWithTableViewBuilder:(TMTableViewBuilder *)tableviewBuilder;
@end
