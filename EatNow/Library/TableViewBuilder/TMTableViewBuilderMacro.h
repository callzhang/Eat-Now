//
//  TMTableViewBuilderMacro.h
//  WaiJiaoLaiLe
//
//  Created by Zitao Xiong on 4/21/15.
//  Copyright (c) 2015 Zitao Xiong. All rights reserved.
//

#ifndef TMTableViewBuilderMacro_h
#define TMTableViewBuilderMacro_h
#ifndef TMP_REQUIRES_SUPER
#if __has_attribute(objc_requires_super)
#define TMP_REQUIRES_SUPER __attribute__((objc_requires_super))
#else
#define TMP_REQUIRES_SUPER
#endif
#endif
#endif
