//
//  FBKVOController+Binding.m
//  VideoGuide
//
//  Created by Zitao Xiong on 3/25/15.
//  Copyright (c) 2015 Nanaimostudio. All rights reserved.
//

#import "FBKVOController+Binding.h"
#import "DDLog.h"

@implementation FBKVOController (Binding)
- (void)bindObserver:(NSObject *)observer keyPath:(NSString *)observerKeyPath toSubject:(NSObject *)subject keyPath:(NSString *)subjectKeyPath {
    [self bindObserver:observer keyPath:observerKeyPath toSubject:subject keyPath:subjectKeyPath withValueTransform:nil];
}

- (void)bindObserver:(NSObject *)observer keyPath:(NSString *)observerKeyPath toSubject:(NSObject *)subject keyPath:(NSString *)subjectKeyPath withValueTransform:(id (^)(id))transformBlock {
    [self observe:observer keyPath:observerKeyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        id newValue = change[NSKeyValueChangeNewKey];
        if (transformBlock) {
            newValue = transformBlock(newValue);
        }
        
        [subject setValue:newValue forKeyPath:subjectKeyPath];
    }];
}

- (void)observe:(id)observer keyPath:(NSString *)keyPath block:(void (^)(id observer, id object, id change))block {
    [self observe:observer keyPath:keyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        id newValue = change[NSKeyValueChangeNewKey];
        if (block) {
            block(observer, object, newValue);
        }
    }];
}

- (void)observe:(id)observer keyPaths:(NSArray *)keyPaths block:(void (^)(id, id, id))block {
    [self observe:observer keyPaths:keyPaths options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        id newValue = change[NSKeyValueChangeNewKey];
        if (block) {
            block(object, object, newValue);
        }
    }];
}



@end

@implementation NSObject (SVRBinding)
- (void)bindKeyPath:(NSString *)keyPath toObject:(id)object toKeyPath:(NSString *)anotherKeypath {
    [self bindKeyPath:keyPath toObject:object toKeyPath:anotherKeypath map:nil];
}

- (void)bindKeyPath:(NSString *)keyPath toObject:(id)object toKeyPath:(NSString *)anotherKeypath map:(id (^)(id change))mapBlock {
    [self bindKeypath:keyPath toObject:object withChangeBlock:^(id object, id change) {
        id value = change;
        if (mapBlock) {
            value = mapBlock(value);
        }
        [object setValue:value forKeyPath:anotherKeypath];
    }];
}

- (void)bindKeypath:(NSString *)keyPath toLabel:(UILabel *)textLabel map:(id (^)(id))block {
    [self bindKeypath:keyPath toObject:textLabel withChangeBlock:^(UILabel *label, id change) {
        if (change) {
            if (block) {
                change = block(change);
            }
            if ([change isKindOfClass:[NSString class]]) {
                label.text = change;
            }
            else if ([change isKindOfClass:[NSNumber class]]) {
                label.text = [(NSNumber *)change stringValue];
            }
            else if ([change isKindOfClass:[NSAttributedString class]]) {
                label.attributedText = change;
            }
            else {
                DDLogError(@"change %@ not supported", change);
                label.text = @"";
            }
        }
        else {
            label.text = @"";
        }
    }];
}

- (void)bindKeypath:(NSString *)keyPath toLabel:(UILabel *)textLabel {
    [self bindKeypath:keyPath toLabel:textLabel map:nil];
}


- (void)bindKeypath:(NSString *)keyPath toImageView:(UIImageView *)imageView {
    [self bindKeypath:keyPath toObject:imageView withChangeBlock:^(UIImageView *aImageView, id change) {
        if ([change isKindOfClass:[UIImage class]]) {
            aImageView.image = change;
        }
        else {
            DDLogVerbose(@"image :%@ not handle", change);
        }
    }];
}

- (void)bindKeypath:(NSString *)keyPath toObject:(id)toObject withChangeBlock:(void (^)(id toObject, id change))block {
    [self.KVOController observe:self keyPath:keyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        id changeObject = [change valueForKey:NSKeyValueChangeNewKey];
        if (block) {
            if ([changeObject isKindOfClass:[NSNull class]]) {
                changeObject = nil;
            }
            block(toObject, changeObject);
        }
    }];
}

- (void)bindKeypath:(NSString *)keyPath withChangeBlock:(void (^)(id change))block {
    [self.KVOController observe:self keyPath:keyPath options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        id changeObject = [change valueForKey:NSKeyValueChangeNewKey];
        if (block) {
            if ([changeObject isKindOfClass:[NSNull class]]) {
                changeObject = nil;
            }
            block(changeObject);
        }
    }];
}

- (void)unbind {
    [self.KVOController unobserveAll];
}
@end