import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:device_calendar_extended/device_calendar_extended.dart';
import 'package:device_calendar_extended/models.dart';

void main() {
  const MethodChannel channel = MethodChannel('device_calendar_extended');
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group('Calendar', () {
    DeviceCalendarExtended plugin;
    Iterable<Calendar> calendars;

    setUp(() async {
      plugin = DeviceCalendarExtended();
      final calendarsResult = await plugin.retrieveCalendars();
      calendars = calendarsResult?.data;
    });

    tearDown(() {
      plugin = null;
      calendars = null;
    });

    test('DeviceCalendarExtended', () {
      expect(plugin, isNot(equals(null)));
    });

    test('retrieveCalendars()', () {
      final Iterable<String> ids = calendars.map((final Calendar c) => c.id);

      expect(calendars.isNotEmpty, true, reason: 'Should not be empty');
      expect(ids.length, ids.toSet().length, reason: 'Should have unique ids');
    });

    test('retrieveEvents()', () async {
      final Calendar calendar = calendars.first;
      final startDate = DateTime.now().add(Duration(days: -30));
      final endDate = DateTime.now().add(Duration(days: 30));
      final calendarEventsResult = await plugin.retrieveEvents(calendar.id,
          RetrieveEventsParams(startDate: startDate, endDate: endDate));
      final Iterable<Event> events = calendarEventsResult?.data;
      final Iterable<String> ids = events.map((final Event c) => c.eventId);

      expect(events.isNotEmpty, true, reason: 'Should not be empty');
      expect(ids.length, ids.toSet().length, reason: 'Should have unique ids');
    });
  });
}