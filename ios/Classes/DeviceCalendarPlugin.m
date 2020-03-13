#import "DeviceCalendarPlugin.h"
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>
#import "models/Calendar.h"
#import "models/RecurrenceRule.h"
#import "models/Event.h"
#import "models/Attendee.h"
#import "models/Reminder.h"
#import "models/Department.h"
#import "Date+Utilities.h"
#import "EKParticipant+Utilities.h"
#import <objc/runtime.h>

@implementation DeviceCalendarPlugin
NSString *streamName = @"calendarChangeEvent/stream";
NSString *methodChannelName = @"plugins.rescomms.com/device_calendar";
NSString *notFoundErrorCode = @"404";
NSString *notAllowed = @"405";
NSString *genericError = @"500";
NSString *unauthorizedErrorCode = @"401";
NSString *unauthorizedErrorMessage = @"The user has not allowed this application to modify their calendar(s)";
NSString *calendarNotFoundErrorMessageFormat = @"The calendar with the ID %@ could not be found";
NSString *calendarReadOnlyErrorMessageFormat = @"Calendar with ID %@ is read-only";
NSString *eventNotFoundErrorMessageFormat = @"The event with the ID %@ could not be found";
NSString *requestPermissionsMethod = @"requestPermissions";
NSString *hasPermissionsMethod = @"hasPermissions";
NSString *retrieveCalendarsMethod = @"retrieveCalendars";
NSString *retrieveEventsMethod = @"retrieveEvents";
NSString *createOrUpdateEventMethod = @"createOrUpdateEvent";
NSString *deleteEventMethod = @"deleteEvent";
NSString *calendarIdArgument = @"calendarId";
NSString *startDateArgument = @"startDate";
NSString *endDateArgument = @"endDate";
NSString *eventIdArgument = @"eventId";
NSString *eventIdsArgument = @"eventIds";
NSString *eventTitleArgument = @"eventTitle";
NSString *eventDescriptionArgument = @"eventDescription";
NSString *eventStartDateArgument =  @"eventStartDate";
NSString *eventEndDateArgument = @"eventEndDate";
NSString *eventLocationArgument = @"eventLocation";
NSString *attendeesArgument = @"attendees";
NSString *recurrenceRuleArgument = @"recurrenceRule";
NSString *recurrenceFrequencyArgument = @"recurrenceFrequency";
NSString *totalOccurrencesArgument = @"totalOccurrences";
NSString *intervalArgument = @"interval";
NSString *daysOfTheWeekArgument = @"daysOfTheWeek";
NSString *daysOfTheMonthArgument = @"daysOfTheMonth";
NSString *monthsOfTheYearArgument = @"monthsOfTheYear";
NSString *weeksOfTheYearArgument = @"weeksOfTheYear";
NSString *setPositionsArgument = @"setPositions";
NSString *emailAddressArgument = @"emailAddress";
NSString *remindersArgument = @"reminders";
NSString *minutesArgument = @"minutes";
NSMutableArray *validFrequencyTypes;
EKEventStore *eventStore;
FlutterEventSink eventSink;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(storeChanged:) name:EKEventStoreChangedNotification object:nil];
    }
    return self;
}

-(void)storeChanged: (NSNotification *)notification {
    eventSink(@"success");
}

- (FlutterError *)onCancelWithArguments:(id)arguments{
    eventSink = nil;
    return nil;
}

- (FlutterError *)onListenWithArguments:(id)arguments eventSink:(FlutterEventSink)events {
    eventSink = events;
    return nil;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName: methodChannelName
                                     binaryMessenger:[registrar messenger]];
    eventStore = [[EKEventStore alloc] init];
    validFrequencyTypes = [NSMutableArray new];
    [validFrequencyTypes addObject: [[NSNumber alloc] initWithInt:EKRecurrenceFrequencyDaily]];
    [validFrequencyTypes addObject: [[NSNumber alloc] initWithInt:EKRecurrenceFrequencyWeekly]];
    [validFrequencyTypes addObject: [[NSNumber alloc] initWithInt:EKRecurrenceFrequencyMonthly]];
    [validFrequencyTypes addObject: [[NSNumber alloc] initWithInt:EKRecurrenceFrequencyYearly]];
    DeviceCalendarPlugin* instance = [[DeviceCalendarPlugin alloc] init];
    FlutterEventChannel *eventChannel = [FlutterEventChannel eventChannelWithName:streamName binaryMessenger:registrar.messenger];
    [eventChannel setStreamHandler: instance];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    NSString *method = call.method;
    if ([method isEqualToString: requestPermissionsMethod]) {
        [self requestPermissions:nil result:result];
        return;
    }
    else if([method isEqualToString: hasPermissionsMethod]) {
        [self hasPermissions:nil result:result];
        return;
    }
    else if ([method isEqualToString: retrieveCalendarsMethod]) {
        [self retrieveCalendars:nil result:result];
        return;
    }
    else if ([method isEqualToString: retrieveEventsMethod]) {
        [self retrieveEvents:call result:result];
        return;
    }
    else if ([method isEqualToString: createOrUpdateEventMethod]) {
        [self createOrUpdateEvent:call result:result];
        return;
    }
    else if ([method isEqualToString: deleteEventMethod]) {
        [self deleteEvent:call result:result];
        return;
    }
    else
        result(FlutterMethodNotImplemented);
}

-(void)hasPermissions:(id)args result:(FlutterResult)result {
    result([NSNumber numberWithBool:[self hasPermissions]]);
}

-(void)retrieveCalendars:(id)args result:(FlutterResult)result{
    Department *department = [Department new];
    department.calendars = [NSMutableArray new];
    [self checkPermissionsThenExecute:nil permissionsGrantedAction:^{
        NSArray<EKCalendar *>  *ekcalendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
        for (EKCalendar* ekCalendar in ekcalendars) {
            
            Calendar *calendar = [Calendar new];
            calendar.id = ekCalendar.calendarIdentifier;
            calendar.name = ekCalendar.title;
            calendar.isReadOnly = !ekCalendar.allowsContentModifications;
            [department.calendars addObject:calendar];
        }
        [self encodeJsonAndFinish:department result:result];
    } result:result];
}

-(void)retrieveEvents:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self checkPermissionsThenExecute:nil permissionsGrantedAction:^{
        NSDictionary *arguments = call.arguments;
        NSString *calendarId = [arguments valueForKey:calendarIdArgument];
        NSNumber *startDateMillisecondsSinceEpoch = [arguments valueForKey:startDateArgument];
        NSNumber *endDateMillisecondsSinceEpoch = [arguments valueForKey:endDateArgument];
        NSArray *_Nullable eventIds = [arguments valueForKey:eventIdsArgument];
        Department *department = [[Department alloc] init];
        department.events = [NSMutableArray new];
        NSMutableArray *events = [NSMutableArray new];
        BOOL specifiedStartEndDates = startDateMillisecondsSinceEpoch != nil && endDateMillisecondsSinceEpoch != nil;
        if (specifiedStartEndDates) {
            NSDate *startDate = [[NSDate alloc] initWithTimeIntervalSince1970: [startDateMillisecondsSinceEpoch doubleValue] / 1000.0];
            NSDate *endDate = [[NSDate alloc] initWithTimeIntervalSince1970: [endDateMillisecondsSinceEpoch doubleValue] / 1000.0];
            EKCalendar *ekCalendar = [eventStore calendarWithIdentifier: calendarId];
            NSMutableArray *calendars = [NSMutableArray new];
            [calendars addObject:ekCalendar];
            NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:startDate endDate:endDate calendars:calendars];
            NSArray *ekEvents = [eventStore eventsMatchingPredicate:predicate];
            for (EKEvent* ekEvent in ekEvents) {
                Event *event = [self createEventFromEkEvent:calendarId event:ekEvent];
                [events addObject:event];
            }
        }
        
        if (eventIds == [NSNull null]) {
            for (Event *event in events) {
                [department.events addObject:event];
            }
            [self encodeJsonAndFinish:department result:result];
            return;
        }
        if (specifiedStartEndDates) {
            for (Event *event in events) {
                if (event.calendarId == calendarId && [eventIds containsObject:event.eventId]) {
                    [department.events addObject:event];
                }
            }
            [self encodeJsonAndFinish:department result:result];
            return;
        }
        for (NSString *eventId in eventIds) {
            EKEvent *ekEvent = [eventStore eventWithIdentifier:eventId];
            if (ekEvent != nil) {
                continue;
            }
            Event *event = [self createEventFromEkEvent:calendarId event:ekEvent];
            [department.events addObject:event];
        }
        [self encodeJsonAndFinish:department result:result];
    } result: result];
}

-(Event*)createEventFromEkEvent: (NSString *)calendarId event:(EKEvent *)ekEvent {
    NSMutableArray *attendees = [NSMutableArray new];
    if ([ekEvent attendees] != nil) {
        for(EKParticipant *ekParticipant in [ekEvent attendees]) {
            Attendee *attendee = [self convertEkParticipantToAttendee:ekParticipant];
            if (attendee == nil) {
                continue;
            }
            [attendees addObject:attendee];
        }
    }
    
    NSMutableArray *reminders = [NSMutableArray new];
    if ([ekEvent alarms] != nil) {
        for (EKAlarm *alarm in [ekEvent alarms]) {
            Reminder *reminder = [Reminder new];
            NSUInteger minutes = -[alarm relativeOffset]/60;
            reminder.minutes = [[[NSNumber alloc] initWithUnsignedInteger:minutes] integerValue];
            [reminders addObject:reminder];
        }
    }

    RecurrenceRule *recurrenceRule = [self parseEKRecurrenceRules:ekEvent];
    Event *event = [Event new];
    event.eventId = [ekEvent eventIdentifier];
    event.calendarId = calendarId;
    event.title = [ekEvent title];
    event.notes = [ekEvent notes];
    event.start = [[[NSNumber alloc] initWithFloat:[[ekEvent startDate] millisecondsSinceEpoch]] integerValue];
    event.end = [[[NSNumber alloc] initWithFloat:[[ekEvent endDate] millisecondsSinceEpoch]] integerValue];
    event.allDay = [ekEvent isAllDay];
    event.attendees = attendees;
    event.location = [ekEvent location];
    event.recurrenceRule = recurrenceRule;
    event.organizer = [self convertEkParticipantToAttendee:[ekEvent organizer]];
    event.reminders = reminders;
    return event;
}

-(Attendee*)convertEkParticipantToAttendee: (EKParticipant *)ekParticipant {
    if (ekParticipant == nil || [ekParticipant emailAddress] == nil) {
        return nil;
    }
    Attendee *attendee = [Attendee new];
    attendee.name = [ekParticipant name];
    attendee.emailAddress = [ekParticipant emailAddress];
    attendee.role = [ekParticipant participantRole];
    return attendee;
}

-(RecurrenceRule *)parseEKRecurrenceRules:(EKEvent *)ekEvent {
    RecurrenceRule *recurrenceRule = [RecurrenceRule new];
    if ([ekEvent hasRecurrenceRules]) {
        EKRecurrenceRule *ekRecurrenceRule = [[ekEvent recurrenceRules] firstObject];
        NSInteger frequency;
        switch ([ekRecurrenceRule frequency]) {
            case EKRecurrenceFrequencyDaily:
                frequency = 0;
                break;
            case EKRecurrenceFrequencyWeekly:
                frequency = 1;
                break;
            case EKRecurrenceFrequencyMonthly:
                frequency = 2;
                break;
            case EKRecurrenceFrequencyYearly:
                frequency = 3;
                break;
            default:
                frequency = 0;
                break;
        }
        
        NSInteger totalOccurrences = 0;
        NSInteger endDate;
        if([[ekRecurrenceRule recurrenceEnd] occurrenceCount] != 0){
            totalOccurrences = [[ekRecurrenceRule recurrenceEnd] occurrenceCount];
        }
        float endDateMs = -1;
        endDateMs = [[[ekRecurrenceRule recurrenceEnd] endDate] millisecondsSinceEpoch];
        if (endDateMs != -1) {
            endDate = [[[NSNumber alloc] initWithFloat:endDateMs] integerValue];
        }

        NSMutableArray *daysOfTheWeek = [NSMutableArray new];
        if ([ekRecurrenceRule daysOfTheWeek] != nil && [[ekRecurrenceRule daysOfTheWeek] count] != 0) {
            daysOfTheWeek = [NSMutableArray new];
            for (EKRecurrenceDayOfWeek *dayOfTheWeek in [ekRecurrenceRule daysOfTheWeek]) {
                [daysOfTheWeek addObject: [[NSNumber alloc] initWithInt:[dayOfTheWeek dayOfTheWeek] - 1]];
            }
        }
        recurrenceRule.recurrenceFrequency = frequency;
        recurrenceRule.totalOccurrences = totalOccurrences;
        recurrenceRule.interval = [ekRecurrenceRule interval];
        recurrenceRule.endDate = endDate;
        recurrenceRule.daysOfTheWeek = daysOfTheWeek;
        recurrenceRule.daysOfTheMonth = [self convertToIntArray: [ekRecurrenceRule daysOfTheMonth]];
        recurrenceRule.monthsOfTheYear = [self convertToIntArray: [ekRecurrenceRule monthsOfTheYear]];
        recurrenceRule.weeksOfTheYear = [self convertToIntArray: [ekRecurrenceRule weeksOfTheYear]];
        recurrenceRule.setPositions = [self convertToIntArray: [ekRecurrenceRule setPositions]];
    }
    return recurrenceRule;
}

-(NSArray *)convertToIntArray: (NSArray *)arguments {
    if ([arguments count] == 0) {
        return nil;
    }
    
    NSMutableArray *result = [NSMutableArray new];
    for (NSNumber *element in arguments) {
        [result addObject:[[NSNumber alloc] initWithInt:[element integerValue]]];
    }
    return result;
}


-(NSArray*) createEKRecurrenceRules: (NSDictionary*)arguments {
    NSDictionary *recurrenceRuleArguments = [arguments valueForKey:recurrenceRuleArgument];
    if (recurrenceRuleArguments) {
        return nil;
    }
    
    NSString *recurrenceFrequencyIndex = [recurrenceRuleArguments valueForKey:recurrenceFrequencyArgument];
    NSInteger totalOccurrences = [[recurrenceRuleArguments valueForKey:totalOccurrencesArgument] integerValue];
    NSInteger interval = -1;
    interval = [[recurrenceRuleArguments valueForKey:intervalArgument] integerValue];
    NSInteger recurrenceInterval = 1;
    NSNumber *endDate = [recurrenceRuleArguments valueForKey:endDateArgument];
    EKRecurrenceFrequency namedFrequency = [[validFrequencyTypes valueForKey:recurrenceFrequencyIndex] integerValue];
    EKRecurrenceEnd *recurrenceEnd;
    
    if (endDate != nil) {
        recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithEndDate: [[NSDate alloc] initWithTimeIntervalSince1970: [endDate doubleValue]]];
    } else if (totalOccurrences > 0){
        recurrenceEnd = [EKRecurrenceEnd recurrenceEndWithOccurrenceCount: totalOccurrences];
    }
    if (interval != -1 && interval > 1) {
        recurrenceInterval = interval;
    }
    
    NSArray *daysOfTheWeekIndices = [recurrenceRuleArguments valueForKey:daysOfTheWeekArgument];
    NSMutableArray *daysOfTheWeek;
    
    if (daysOfTheWeek != nil && [daysOfTheWeekIndices count] == 0) {
        daysOfTheWeek = [NSMutableArray new];
        for (NSNumber *dayOfWeekIndex in daysOfTheWeekIndices) {
            EKRecurrenceDayOfWeek *dayOfTheWeek = [EKRecurrenceDayOfWeek dayOfWeek:[dayOfWeekIndex integerValue] + 1];
            [daysOfTheWeek addObject: dayOfTheWeek];
        }
    }
    NSMutableArray *ekRecurrenceRules = [NSMutableArray new];
    EKRecurrenceRule *ekRecurrenceRule = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:
     namedFrequency
     interval:recurrenceInterval
     daysOfTheWeek:daysOfTheWeek
     daysOfTheMonth:[recurrenceRuleArguments valueForKey:daysOfTheMonthArgument]
     monthsOfTheYear:[recurrenceRuleArguments valueForKey:monthsOfTheYearArgument]
     weeksOfTheYear:[recurrenceRuleArguments valueForKey:weeksOfTheYearArgument]
     daysOfTheYear:nil
     setPositions:[recurrenceRuleArguments valueForKey:setPositionsArgument]
     end:recurrenceEnd
    ];
    [ekRecurrenceRules addObject: ekRecurrenceRule];
    return ekRecurrenceRules;
}

-(void)setAttendees: (NSDictionary *)arguments event:(EKEvent *)ekEvent{
    NSDictionary *attendeesArguments = [arguments valueForKey:attendeesArgument];
    if (attendeesArguments == nil) {
        return;
    }
    
    NSMutableArray *attendees = [NSMutableArray new];
    for (NSString *attendeeArguments in attendeesArguments) {
        NSString *emailAddress = [attendeeArguments valueForKey:emailAddressArgument];
        if ([ekEvent attendees] != nil) {
            NSArray<EKParticipant*> *participants = [ekEvent attendees];
            EKParticipant *existingAttendee;
            for(EKParticipant* participant in participants) {
                if ([participant emailAddress] == emailAddress) {
                    existingAttendee = participant;
                    break;
                }
            }
            if (existingAttendee != nil && [[ekEvent organizer] emailAddress] != [existingAttendee emailAddress]) {
                [attendees addObject: existingAttendee];
                continue;
            }
            EKParticipant *attendee = [self createParticipant:emailAddress];
            if (attendee == nil) {
                continue;
            }
        }
    }
    [ekEvent setValue:attendees forKey:@"attendees"];
}

-(NSArray*)createReminders: (NSDictionary *)arguments {
    NSDictionary *remindersArguments = [arguments valueForKey:remindersArgument];
    if (remindersArguments == nil) {
        return nil;
    }
    NSMutableArray *reminders = [NSMutableArray new];
    for (NSString *reminderArguments in remindersArguments) {
        NSNumber *arg = [[NSNumber alloc] initWithInt: [reminderArguments valueForKey:minutesArgument]];
        double relativeOffset = 60 * (-[arg doubleValue]);
        [reminders addObject:[EKAlarm alarmWithRelativeOffset:relativeOffset]];
    }
    return reminders;
}

-(void)createOrUpdateEvent: (FlutterMethodCall *)call result:(FlutterResult)result{
    [self checkPermissionsThenExecute:nil permissionsGrantedAction:^{
        NSDictionary<NSString*, id> *arguments = [call arguments];
        NSString *calendarId = [arguments valueForKey:calendarIdArgument];
        NSString *eventId = [arguments valueForKey:eventIdArgument];
        NSNumber *startDateMillisecondsSinceEpoch = [arguments valueForKey: eventStartDateArgument];
        NSNumber *endDateDateMillisecondsSinceEpoch = [arguments valueForKey: eventEndDateArgument];
        NSDate *startDate = [NSDate dateWithTimeIntervalSince1970: [startDateMillisecondsSinceEpoch doubleValue] / 1000.0 ];
        NSDate *endDate = [NSDate dateWithTimeIntervalSince1970: [endDateDateMillisecondsSinceEpoch doubleValue] / 1000.0 ];
        NSString *title = [arguments valueForKey: eventTitleArgument];
        NSString *description = [arguments valueForKey: eventDescriptionArgument];
        NSString *location = [arguments valueForKey: eventLocationArgument];
        EKCalendar *ekCalendar = [eventStore calendarWithIdentifier: calendarId];
        if (ekCalendar == nil) {
            [self finishWithCalendarNotFoundError:calendarId result: result];
            return;
        }
        if (![ekCalendar allowsContentModifications]) {
            [self finishWithCalendarReadOnlyError:calendarId result:result];
            return;
        }
        EKEvent *ekEvent;
        if (eventId == [NSNull null]) {
            ekEvent = [EKEvent eventWithEventStore:eventStore];
        }else {
            ekEvent = [eventStore eventWithIdentifier:eventId];
            if (ekEvent == nil) {
                [self finishWithEventNotFoundError: eventId result: result];
                return;
            }
        }
        [ekEvent setTitle:title];
        [ekEvent setNotes:description];
        [ekEvent setStartDate:startDate];
        [ekEvent setEndDate:endDate];
        [ekEvent setCalendar:ekCalendar];
        [ekEvent setLocation:location];
        [ekEvent setRecurrenceRules: [self createEKRecurrenceRules: arguments]];
        [self setAttendees:arguments event:ekEvent];
        [ekEvent setAlarms: [self createReminders: arguments]];
        
        NSError *error = nil;
        [eventStore saveEvent:ekEvent span:EKSpanFutureEvents error:&error];
        if (error == nil) {
            result([ekEvent eventIdentifier]);
        } else {
            [eventStore reset];
            result([FlutterError errorWithCode:genericError message: [error localizedDescription] details:nil ]);
        }

    } result: result];
}

-(EKParticipant *)createParticipant:(NSString *)emailAddress {
    Class ekAttendeeClass = NSClassFromString(@"EKAttendee");
    if ([ekAttendeeClass isSubclassOfClass:[NSObject class]]) {
        NSObject *participant = [[ekAttendeeClass alloc] init];
        [participant setValue:emailAddress forKey:@"emailAddress"];
        return (EKParticipant *)participant;
    }
    return nil;
}

-(void)deleteEvent:(FlutterMethodCall *)call result:(FlutterResult)result {
    [self checkPermissionsThenExecute:nil permissionsGrantedAction:^{
        NSDictionary<NSString*, id> *arguments = call.arguments;
        NSString *calendarId = [arguments valueForKey:calendarIdArgument];
        NSString *eventId = [arguments valueForKey:eventIdArgument];
        EKCalendar *ekCalendar = [eventStore calendarWithIdentifier: calendarId];
        EKEvent *ekEvent = [eventStore eventWithIdentifier: eventId];
        if (ekCalendar == nil) {
            [self finishWithCalendarNotFoundError:calendarId result: result];
            return;
        }
        if (![ekCalendar allowsContentModifications]) {
            [self finishWithCalendarReadOnlyError:calendarId result: result];
            return;
        }
        if (ekEvent == nil) {
            [self finishWithEventNotFoundError:eventId result: result];
            return;
        }
        NSError *error = nil;
        [eventStore removeEvent:ekEvent span:EKSpanFutureEvents error:&error];
        if (error == nil) {
            result([NSNumber numberWithBool:YES]);
        } else {
            [eventStore reset];
            result([FlutterError errorWithCode:genericError message: [error localizedDescription] details:nil ]);
        }
    } result:result];
}

-(void)finishWithUnauthorizedError:(id)args result:(FlutterResult)result{
    result([FlutterError errorWithCode:unauthorizedErrorCode message:unauthorizedErrorMessage details:nil]);
}

-(void)finishWithCalendarNotFoundError:(NSString *)calendarId result:(FlutterResult)result{
    NSString *errorMessage = [calendarNotFoundErrorMessageFormat stringByAppendingFormat: calendarId];
    result([FlutterError errorWithCode:notFoundErrorCode message:errorMessage details:nil]);
}

-(void)finishWithCalendarReadOnlyError:(NSString *)calendarId result:(FlutterResult)result{
    NSString *errorMessage = [calendarReadOnlyErrorMessageFormat stringByAppendingFormat: calendarId];
    result([FlutterError errorWithCode:notAllowed message:errorMessage details:nil]);
}

-(void)finishWithEventNotFoundError: (NSString *)eventId result:(FlutterResult)result {
    NSString *errorMessage = [eventNotFoundErrorMessageFormat stringByAppendingFormat: eventId];
    result([FlutterError errorWithCode:notFoundErrorCode message:errorMessage details:nil]);
}

-(void)encodeJsonAndFinish: (Department *)codable result:(FlutterResult)result {
    NSMutableArray *resultArr = [NSMutableArray new];
    if ([codable.calendars count] > 0) {
        for(Calendar *calendar in codable.calendars) {
            [resultArr addObject:[calendar toJSONString]];
        }
    } else {
        for(Event *event in codable.events) {
            [resultArr addObject:[event toJSONString]];
        }
    }
    
    NSString * arrayToString = [[resultArr valueForKey:@"description"] componentsJoinedByString:@","];
    NSString *resultStr = [[NSString alloc] initWithFormat:@"[%@]", arrayToString];
    result(resultStr);
}

-(void)checkPermissionsThenExecute:(id)args permissionsGrantedAction:(void (^)(void))permissionsGrantedAction result:(FlutterResult)result {
    if ([self hasPermissions]) {
        permissionsGrantedAction();
        return;
    }
    [self finishWithUnauthorizedError:nil result:result];
}

-(void) selector: (FlutterResult *) result {
    
}

-(void)requestPermissions: completion:(void (^)(BOOL success))complet {
    if ([self hasPermissions]) {
        complet(YES);
    } else {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            complet(granted);
        }];
    }
}

-(BOOL)hasPermissions {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType: EKEntityTypeEvent];
    return status == EKAuthorizationStatusAuthorized;
}

-(void)requestPermissions:(id)args result:(FlutterResult)result {
    if ([self hasPermissions])
        result([NSNumber numberWithBool:YES]);
    [eventStore requestAccessToEntityType: EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        result([NSNumber numberWithBool:granted]);
    }];
}
@end
