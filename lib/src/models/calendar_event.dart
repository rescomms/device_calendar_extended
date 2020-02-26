library calendar_event;

import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

// Depend on generated code bit
part 'calendar_event.g.dart';

///
/// Calendar Event Data Model
///
abstract class CalendarEvent
    implements Built<CalendarEvent, CalendarEventBuilder> {
  static const FullType type = FullType(CalendarEvent);

  /// The unique id for the event (within the device)
  String get id;

  /// The unique id of the calendar (within the device)
  String get calendarId;

  /// The name (title) of the event
  @nullable
  String get name;

  /// The description (body text) of the event
  @nullable
  String get description;

  /// The location of the event
  @nullable
  String get location;

  /// Start time of the event (in UTC)
  DateTime get starts;

  /// End time of the event (in UTC)
  DateTime get ends;

  // Parts that generated code needs
  // Add serialization support by defining this static getter.
  static Serializer<CalendarEvent> get serializer =>
      _$calendarEventSerializer;
  CalendarEvent._();
  factory CalendarEvent([void Function(CalendarEventBuilder) updates]) =
      _$CalendarEvent;
}
