//
//  GCDSingleton.h
//
//  Created by zitao xiong on 10/13/12.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//
//  Reference:
//      https://gist.github.com/1057420
//      http://lukeredpath.co.uk/blog/a-note-on-objective-c-singletons.html
//      https://github.com/cjhanson/Objective-C-Optimized-Singleton

#ifndef IHR_GCDSingleton_h
#define IHR_GCDSingleton_h

#define GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SS_CLASSNAME)	\
\
+ (SS_CLASSNAME*) shared;	\
+ (SS_CLASSNAME*) sharedInstance;	\
+ (SS_CLASSNAME*) shared##SS_CLASSNAME;	

#define GCD_SYNTHESIZE_SINGLETON_FOR_CLASS(SS_CLASSNAME)	\
    \
+ (SS_CLASSNAME *)shared {                      \
    \
    static dispatch_once_t pred;                        \
    __strong static SS_CLASSNAME * shared##SS_CLASSNAME = nil;\
    dispatch_once( &pred, ^{                            \
        shared##SS_CLASSNAME = [[self alloc] init]; });    \
    return shared##SS_CLASSNAME;                           \
}   \
\
+ (SS_CLASSNAME *)sharedInstance {                      \
    return [self shared]; \
}\
+ (SS_CLASSNAME *)shared##SS_CLASSNAME {                      \
    return [self shared]; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \

#define GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER_WITH_ACCESSOR(SS_CLASSNAME, SS_ACCESSORMETHODNAME)	\
\
+ (SS_CLASSNAME*) SS_ACCESSORMETHODNAME;

#define GCD_SYNTHESIZE_SINGLETON_FOR_CLASS_WITH_ACCESSOR(SS_CLASSNAME, SS_ACCESSORMETHODNAME)	\
\
+ (SS_CLASSNAME *)SS_ACCESSORMETHODNAME {                      \
\
static dispatch_once_t pred;                        \
__strong static SS_CLASSNAME * shared##SS_CLASSNAME = nil;\
dispatch_once( &pred, ^{                            \
shared##SS_CLASSNAME = [[self alloc] init]; });    \
return shared##SS_CLASSNAME;                           \
}   \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
return self; \
} \

#endif