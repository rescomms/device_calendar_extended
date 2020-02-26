// GENERATED CODE - DO NOT MODIFY BY HAND

part of calendar_event;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<CalendarEvent> _$calendarEventSerializer =
    new _$CalendarEventSerializer();

class _$CalendarEventSerializer implements StructuredSerializer<CalendarEvent> {
  @override
  final Iterable<Type> types = const [CalendarEvent, _$CalendarEvent];
  @override
  final String wireName = 'CalendarEvent';

  @override
  Iterable<Object> serialize(Serializers serializers, CalendarEvent object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'calendarId',
      serializers.serialize(object.calendarId,
          specifiedType: const FullType(String)),
      'starts',
      serializers.serialize(object.starts,
          specifiedType: const FullType(DateTime)),
      'ends',
      serializers.serialize(object.ends,
          specifiedType: const FullType(DateTime)),
    ];
    if (object.name != null) {
      result
        ..add('name')
        ..add(serializers.serialize(object.name,
            specifiedType: const FullType(String)));
    }
    if (object.description != null) {
      result
        ..add('description')
        ..add(serializers.serialize(object.description,
            specifiedType: const FullType(String)));
    }
    if (object.location != null) {
      result
        ..add('location')
        ..add(serializers.serialize(object.location,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  CalendarEvent deserialize(
      Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new CalendarEventBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final dynamic value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'calendarId':
          result.calendarId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'location':
          result.location = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'starts':
          result.starts = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
        case 'ends':
          result.ends = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime;
          break;
      }
    }

    return result.build();
  }
}

class _$CalendarEvent extends CalendarEvent {
  @override
  final String id;
  @override
  final String calendarId;
  @override
  final String name;
  @override
  final String description;
  @override
  final String location;
  @override
  final DateTime starts;
  @override
  final DateTime ends;

  factory _$CalendarEvent([void Function(CalendarEventBuilder) updates]) =>
      (new CalendarEventBuilder()..update(updates)).build();

  _$CalendarEvent._(
      {this.id,
      this.calendarId,
      this.name,
      this.description,
      this.location,
      this.starts,
      this.ends})
      : super._() {
    if (id == null) {
      throw new BuiltValueNullFieldError('CalendarEvent', 'id');
    }
    if (calendarId == null) {
      throw new BuiltValueNullFieldError('CalendarEvent', 'calendarId');
    }
    if (starts == null) {
      throw new BuiltValueNullFieldError('CalendarEvent', 'starts');
    }
    if (ends == null) {
      throw new BuiltValueNullFieldError('CalendarEvent', 'ends');
    }
  }

  @override
  CalendarEvent rebuild(void Function(CalendarEventBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CalendarEventBuilder toBuilder() => new CalendarEventBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CalendarEvent &&
        id == other.id &&
        calendarId == other.calendarId &&
        name == other.name &&
        description == other.description &&
        location == other.location &&
        starts == other.starts &&
        ends == other.ends;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc($jc($jc(0, id.hashCode), calendarId.hashCode),
                        name.hashCode),
                    description.hashCode),
                location.hashCode),
            starts.hashCode),
        ends.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('CalendarEvent')
          ..add('id', id)
          ..add('calendarId', calendarId)
          ..add('name', name)
          ..add('description', description)
          ..add('location', location)
          ..add('starts', starts)
          ..add('ends', ends))
        .toString();
  }
}

class CalendarEventBuilder
    implements Builder<CalendarEvent, CalendarEventBuilder> {
  _$CalendarEvent _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _calendarId;
  String get calendarId => _$this._calendarId;
  set calendarId(String calendarId) => _$this._calendarId = calendarId;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  String _description;
  String get description => _$this._description;
  set description(String description) => _$this._description = description;

  String _location;
  String get location => _$this._location;
  set location(String location) => _$this._location = location;

  DateTime _starts;
  DateTime get starts => _$this._starts;
  set starts(DateTime starts) => _$this._starts = starts;

  DateTime _ends;
  DateTime get ends => _$this._ends;
  set ends(DateTime ends) => _$this._ends = ends;

  CalendarEventBuilder();

  CalendarEventBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _calendarId = _$v.calendarId;
      _name = _$v.name;
      _description = _$v.description;
      _location = _$v.location;
      _starts = _$v.starts;
      _ends = _$v.ends;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CalendarEvent other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$CalendarEvent;
  }

  @override
  void update(void Function(CalendarEventBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$CalendarEvent build() {
    final _$result = _$v ??
        new _$CalendarEvent._(
            id: id,
            calendarId: calendarId,
            name: name,
            description: description,
            location: location,
            starts: starts,
            ends: ends);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
