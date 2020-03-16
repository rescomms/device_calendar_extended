#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "Event.h"
#import "Calendar.h"

@interface Department : JSONModel
@property NSMutableArray<Calendar *> *calendars;
@property NSMutableArray<Event *> *events;
@end
