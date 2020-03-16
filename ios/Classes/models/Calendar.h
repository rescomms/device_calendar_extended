#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface Calendar : JSONModel

@property NSString *id;
@property NSString *name;
@property BOOL isReadOnly;

@end
