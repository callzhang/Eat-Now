//
//  TMSectionItem+Protected.h
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "TMSectionItem.h"

@class TMTableViewBuilder;

@interface TMSectionItem (Protected)
@property (nonatomic, readwrite, weak) TMTableViewBuilder *tableViewBuilder;
@end
