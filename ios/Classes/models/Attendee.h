#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface Attendee : JSONModel

@property NSString *name;
@property NSString *emailAddress;
@property NSInteger role;
@property NSInteger attendanceStatus;

@end
