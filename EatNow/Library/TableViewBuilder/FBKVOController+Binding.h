//
//  FBKVOController+Binding.h
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "FBKVOController.h"

@interface FBKVOController (Binding)
- (void)bindObserver:(NSObject *)observer keyPath:(NSString *)observerKeyPath toSubject:(NSObject *)subject keyPath:(NSString *)subjectKeyPath;

- (void)bindObserver:(NSObject *)observer keyPath:(NSString *)observerKeyPath toSubject:(NSObject *)subject keyPath:(NSString *)subjectKeyPath withValueTransform:(id(^)(id value))transformBlock;
- (void)observe:(id)observer keyPath:(NSString *)keyPath block:(void (^)(id observer, id object, id change))block;
- (void)observe:(id)observer keyPaths:(NSArray *)keyPaths block:(void (^)(id observer, id object, id change))block;



@end

@interface NSObject (SVRBinding)
#pragma mark -
#pragma mark - Binding
- (void)bindKeyPath:(NSString *)keyPath toObject:(id)object toKeyPath:(NSString *)anotherKeypath;
- (void)bindKeyPath:(NSString *)keyPath toObject:(id)object toKeyPath:(NSString *)anotherKeypath map:(id (^)(id change))mapBlock;

- (void)bindKeypath:(NSString *)keyPath toLabel:(UILabel *)textLabel;
- (void)bindKeypath:(NSString *)keyPath toLabel:(UILabel *)textLabel map:(id(^)(id change))block;
- (void)bindKeypath:(NSString *)keyPath toImageView:(UIImageView *)imageView;
- (void)bindKeypath:(NSString *)keyPath toObject:(id)object withChangeBlock:(void (^)(id object, id change))block;
- (void)bindKeypath:(NSString *)keyPath withChangeBlock:(void (^)(id change))block;
- (void)unbind;
@end