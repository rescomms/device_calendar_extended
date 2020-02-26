///
/// Serializers to turn the DataModels into JSON
/// See https://medium.com/dartlang/darts-built-value-for-serialization-f5db9d0f4159
///

library serializers;

import 'package:built_collection/built_collection.dart';
import 'package:built_value/iso_8601_date_time_serializer.dart';
import 'package:built_value/serializer.dart';
import 'package:device_calendar_extended/models.dart';

part 'serializers.g.dart';

// Gather together all the generated serializers. Support JSON
// and DateTime serializers
@SerializersFor(<Type>[
  Calendar,
  CalendarEvent
])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(Iso8601DateTimeSerializer())
      ..addBuilderFactory(
          const FullType(BuiltList, <FullType>[FullType(Calendar)]),
          () => ListBuilder<Calendar>())
      ..addBuilderFactory(
          const FullType(BuiltList, <FullType>[FullType(CalendarEvent)]),
          () => ListBuilder<CalendarEvent>())
    )
    .build();
