#import <Foundation/Foundation.h>
#import "JSONModel.h"

@interface RecurrenceRule : JSONModel

@property NSInteger recurrenceFrequency;
@property NSInteger totalOccurrences;
@property NSInteger interval;
@property NSInteger endDate;
@property NSArray *daysOfTheWeek;
@property NSArray *daysOfTheMonth;
@property NSArray *monthsOfTheYear;
@property NSArray *weeksOfTheYear;
@property NSArray *setPositions;

@end
