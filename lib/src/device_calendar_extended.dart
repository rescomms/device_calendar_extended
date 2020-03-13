import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:device_calendar_extended/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'common/error_codes.dart';
import 'common/error_messages.dart';
import 'models/calendar.dart';
import 'models/event.dart';
import 'models/result.dart';
import 'models/retrieve_events_params.dart';

///
/// Provides native calendar connectivity. The class is implemented as Singleton,
/// so that a single instance is alive a time.
///
class DeviceCalendarExtended {
  static const MethodChannel channel =
  const MethodChannel('plugins.rescomms.com/device_calendar');

  static final DeviceCalendarExtended _instance = DeviceCalendarExtended.private();
  factory DeviceCalendarExtended() {
    return _instance;
  }

  @visibleForTesting
  DeviceCalendarExtended.private();

  /// Requests permissions to modify the calendars on the device
  ///
  /// Returns a [Result] indicating if calendar READ and WRITE permissions
  /// have (true) or have not (false) been granted
  Future<Result<bool>> requestPermissions() async {
    final res = Result<bool>();

    try {
      res.data = await channel.invokeMethod('requestPermissions');
    } catch (e) {
      _parsePlatformExceptionAndUpdateResult<bool>(e, res);
    }

    return res;
  }

  /// Checks if permissions for modifying the device calendars have been granted
  ///
  /// Returns a [Result] indicating if calendar READ and WRITE permissions
  /// have (true) or have not (false) been granted
  Future<Result<bool>> hasPermissions() async {
    final res = Result<bool>();

    try {
      res.data = await channel.invokeMethod('hasPermissions');
    } catch (e) {
      _parsePlatformExceptionAndUpdateResult<bool>(e, res);
    }

    return res;
  }

  /// Retrieves all of the device defined calendars
  ///
  /// Returns a [Result] containing a list of device [Calendar]
  Future<Result<UnmodifiableListView<Calendar>>> retrieveCalendars() async {
    final res = Result<UnmodifiableListView<Calendar>>();

    try {
      var calendarsJson = await channel.invokeMethod('retrieveCalendars');
      res.data = UnmodifiableListView(
          json.decode(calendarsJson).map<Calendar>((decodedCalendar) {
            return Calendar.fromJson(decodedCalendar);
          }));
    } catch (e) {
      _parsePlatformExceptionAndUpdateResult<UnmodifiableListView<Calendar>>(
          e, res);
    }

    return res;
  }

  /// Retrieves the events from the specified calendar
  ///
  /// The `calendarId` paramter is the id of the calendar that plugin will return events for
  /// The `retrieveEventsParams` parameter combines multiple properties that
  /// specifies conditions of the events retrieval. For instance, defining [RetrieveEventsParams.startDate]
  /// and [RetrieveEventsParams.endDate] will return events only happening in that time range
  ///
  /// Returns a [Result] containing a list [Event], that fall
  /// into the specified parameters
  Future<Result<UnmodifiableListView<Event>>> retrieveEvents(
      String calendarId, RetrieveEventsParams retrieveEventsParams) async {
    final res = Result<UnmodifiableListView<Event>>();

    if ((calendarId?.isEmpty ?? true)) {
      res.errorMessages.add(
          "[${ErrorCodes.invalidArguments}] ${ErrorMessages.invalidMissingCalendarId}");
    }

    // TODO: Extend capability to handle null start or null end (e.g. all events after a certain date (null end date) or all events prior to a certain date (null start date))
    if ((retrieveEventsParams?.eventIds?.isEmpty ?? true) &&
        ((retrieveEventsParams?.startDate == null ||
            retrieveEventsParams?.endDate == null) ||
            (retrieveEventsParams.startDate != null &&
                retrieveEventsParams.endDate != null &&
                retrieveEventsParams.startDate
                    .isAfter(retrieveEventsParams.endDate)))) {
      res.errorMessages.add(
          "[${ErrorCodes.invalidArguments}] ${ErrorMessages.invalidRetrieveEventsParams}");
    }


    if (res.errorMessages.isEmpty) {
      try {
        var eventsJson =
        await channel.invokeMethod('retrieveEvents', <String, Object>{
          'calendarId': calendarId,
          'startDate': retrieveEventsParams.startDate?.millisecondsSinceEpoch,
          'endDate': retrieveEventsParams.endDate?.millisecondsSinceEpoch,
          'eventIds': retrieveEventsParams.eventIds
        });

        res.data = UnmodifiableListView(
            json.decode(eventsJson).map<Event>((decodedEvent) {
              return Event.fromJson(decodedEvent as Map<String, dynamic>);
            }));
      } catch (e) {
        _parsePlatformExceptionAndUpdateResult<UnmodifiableListView<Event>>(
            e, res);
      }
    }

    return res;
  }

  /// Deletes an event from a calendar. For a recurring event, this will delete all instances of it
  ///
  /// The `calendarId` paramter is the id of the calendar that plugin will try to delete the event from
  /// The `eventId` parameter is the id of the event that plugin will try to delete
  ///
  /// Returns a [Result] indicating if the event has (true) or has not (false) been deleted from the calendar
  Future<Result<bool>> deleteEvent(String calendarId, String eventId) async {
    final res = Result<bool>();

    if ((calendarId?.isEmpty ?? true) || (eventId?.isEmpty ?? true)) {
      res.errorMessages.add(
          "[${ErrorCodes.invalidArguments}] ${ErrorMessages.deleteEventInvalidArgumentsMessage}");
      return res;
    }

    try {
      res.data = await channel.invokeMethod('deleteEvent',
          <String, Object>{'calendarId': calendarId, 'eventId': eventId});
    } catch (e) {
      _parsePlatformExceptionAndUpdateResult<bool>(e, res);
    }

    return res;
  }

  /// Creates or updates an event
  ///
  /// The `event` paramter specifies how event data should be saved into the calendar
  /// Always specify the [Event.calendarId], to inform the plugin in which calendar
  /// it should create or update the event.
  ///
  /// Returns a [Result] with the newly created or updated [Event.eventId]
  Future<Result<String>> createOrUpdateEvent(Event event) async {
    final res = Result<String>();

    if ((event?.calendarId?.isEmpty ?? true) ||
        event.start == null ||
        event.end == null ||
        event.start.isAfter(event.end)) {
      res.errorMessages.add(
          "[${ErrorCodes.invalidArguments}] ${ErrorMessages.createOrUpdateEventInvalidArgumentsMessage}");
      return res;
    }

    try {
      res.data =
      await channel.invokeMethod('createOrUpdateEvent', <String, Object>{
        'calendarId': event.calendarId,
        'eventId': event.eventId,
        'eventTitle': event.title,
        'eventDescription': event.notes,
        'eventLocation': event.location,
        'eventStartDate': event.start.millisecondsSinceEpoch,
        'eventEndDate': event.end.millisecondsSinceEpoch,
        'eventLocation': event.location,
        'recurrenceRule': event.recurrenceRule?.toJson(),
        'attendees': event.attendees?.map((a) => a.toJson())?.toList(),
        'reminders': event.reminders?.map((r) => r.toJson())?.toList()
      });
    } catch (e) {
      _parsePlatformExceptionAndUpdateResult<String>(e  as Exception, res);
    }
    return res;
  }

  void _parsePlatformExceptionAndUpdateResult<T>(
      Exception exception, Result<T> result) {
    if (exception == null) {
      result.errorMessages.add(
          "[${ErrorCodes.unknown}] Device calendar plugin ran into an unknown issue");
      return;
    }

    if (exception is PlatformException) {
      result.errorMessages.add(
          "[${ErrorCodes.platformSpecific}] Device calendar plugin ran into an issue. Platform specific exception [${exception.code}], with message :\"${exception.message}\", has been thrown.");
    } else {
      result.errorMessages.add(
          "[${ErrorCodes.generic}] Device calendar plugin ran into an issue, with message \"${exception.toString()}\"");
    }
  }
}