//
//  ENDefines.h
//  EatNow
//
//  Created by Lee on 1/29/15.
//  Copyright (c) 2015 modocache. All rights reserved.
//

#ifndef EatNow_ENDefines_h
#define EatNow_ENDefines_h

#define ENAlert(str)                    [[[UIAlertView alloc] initWithTitle:@"Alert" message:str delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
#define TIC                             NSDate *ticStartTime = [NSDate date];
#define TOC                             NSLog(@"Time: %f", -[ticStartTime timeIntervalSinceNow]);
#endif
