//
//
//  Created by Zitao Xiong on 14/09/2014.
//

//#import "EWServerObject.h"
@class EWServerObject;

typedef void (^DictionaryBlock)(NSDictionary *dictionary);
typedef void (^BoolBlock)(BOOL success);
typedef void (^BoolErrorBlock)(BOOL success, NSError *error);
typedef void (^DictionaryErrorBlock)(NSDictionary *dictioanry, NSError *error);
typedef void (^ErrorBlock)(NSError *error);
typedef void (^VoidBlock)(void);
typedef void (^ArrayBlock)(NSArray *array, NSError *error);
typedef void (^FloatBlock)(float percent);
typedef void (^SenderBlock)(id sender);
typedef void (^ManagedObjectErrorBlock)(EWServerObject *MO, NSError *error);
typedef void (^tableViewCellLayoutBlock)(UITableViewCell *cell);