library calendar;

import 'dart:core';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

// Depend on generated code bit
part 'calendar.g.dart';

///
/// Calendar Data Model
///
abstract class Calendar
    implements Built<Calendar, CalendarBuilder> {
  static const FullType type = FullType(Calendar);

  /// The unique id of the calendar (within the device)
  String get id;

  /// The name of the calendar
  String get name;

  /// Whether or not the calendar is read-only
  bool get readOnly;

  // Parts that the generated code needs
  // Add serialization support by defining this static getter.
  static Serializer<Calendar> get serializer =>
      _$calendarSerializer;
  Calendar._();
  factory Calendar([void Function(CalendarBuilder) updates]) =
      _$Calendar;

}
