import 'dart:async';

import 'package:built_collection/built_collection.dart';
import 'package:device_calendar_extended/models.dart';
import 'package:flutter/services.dart';

// Mock data that should be removed as soon as a real implementation is available
final Calendar _mockBirthdayCalendar = Calendar((final CalendarBuilder b) => b
  ..id = '1'
  ..name = 'Birthdays'
  ..readOnly = true
);
final Calendar _mockCalendar = Calendar((final CalendarBuilder b) => b
  ..id = '2'
  ..name = 'Public holidays'
  ..readOnly = false
);
final CalendarEvent _mockEvent = CalendarEvent((final CalendarEventBuilder b) => b
  ..id = '1'
  ..calendarId = '2'
  ..name = 'Some telco'
  ..description = 'Here is some body text for the event'
  ..starts = DateTime.utc(2020, 2, 26, 9, 30)
  ..ends = DateTime.utc(2020, 2, 26, 10, 30)
  ..location = 'Hangouts (+ some link here)'
);
final CalendarEvent _mockEvent2 = CalendarEvent((final CalendarEventBuilder b) => b
  ..id = '2'
  ..calendarId = '2'
  ..name = 'Some telco 2'
  ..description = 'Here is some body text for the event 2'
  ..starts = DateTime.utc(2020, 2, 27, 9, 30)
  ..ends = DateTime.utc(2020, 2, 27, 10, 30)
  ..location = 'Hangouts (+ some link here)'
);

///
/// Provides native calendar connectivity. The class is implemented as Singleton,
/// so that a single instance is alive a time.
///
class DeviceCalendarExtended {
  static const MethodChannel _channel =
      MethodChannel('device_calendar_extended');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static final DeviceCalendarExtended _instance = DeviceCalendarExtended.private();

  /// Returns a handle to the singleton instance
  factory DeviceCalendarExtended() {
    return _instance;
  }

  /// Singleton private constructor
  DeviceCalendarExtended.private();

  Future<BuiltSet<Calendar>> retrieveCalendars() async {
    return BuiltSet<Calendar>(<Calendar>[
      _mockBirthdayCalendar,
      _mockCalendar,
    ]);
  }

  Future<BuiltSet<CalendarEvent>> retrieveEvents(final String calendarId, {
    final DateTime starts,
    final DateTime ends,
    final BuiltSet<String> eventIds
  }) async {
    return BuiltSet<CalendarEvent>(<CalendarEvent>[
      _mockEvent
    ]);
  }

  Future<CalendarEvent> retrieveEvent(final String calendarId, final String eventId) async {
    final Iterable<CalendarEvent> events = await retrieveEvents(
      calendarId,
      eventIds: BuiltSet<String>(<String>[eventId]),
    );
    return events.isEmpty ? null : events.first;
  }
}
