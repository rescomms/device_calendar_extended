// GENERATED CODE - DO NOT MODIFY BY HAND

part of calendar;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Calendar> _$calendarSerializer = new _$CalendarSerializer();

class _$CalendarSerializer implements StructuredSerializer<Calendar> {
  @override
  final Iterable<Type> types = const [Calendar, _$Calendar];
  @override
  final String wireName = 'Calendar';

  @override
  Iterable<Object> serialize(Serializers serializers, Calendar object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'readOnly',
      serializers.serialize(object.readOnly,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  Calendar deserialize(Serializers serializers, Iterable<Object> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new CalendarBuilder();

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
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String;
          break;
        case 'readOnly':
          result.readOnly = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$Calendar extends Calendar {
  @override
  final String id;
  @override
  final String name;
  @override
  final bool readOnly;

  factory _$Calendar([void Function(CalendarBuilder) updates]) =>
      (new CalendarBuilder()..update(updates)).build();

  _$Calendar._({this.id, this.name, this.readOnly}) : super._() {
    if (id == null) {
      throw new BuiltValueNullFieldError('Calendar', 'id');
    }
    if (name == null) {
      throw new BuiltValueNullFieldError('Calendar', 'name');
    }
    if (readOnly == null) {
      throw new BuiltValueNullFieldError('Calendar', 'readOnly');
    }
  }

  @override
  Calendar rebuild(void Function(CalendarBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CalendarBuilder toBuilder() => new CalendarBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Calendar &&
        id == other.id &&
        name == other.name &&
        readOnly == other.readOnly;
  }

  @override
  int get hashCode {
    return $jf($jc($jc($jc(0, id.hashCode), name.hashCode), readOnly.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Calendar')
          ..add('id', id)
          ..add('name', name)
          ..add('readOnly', readOnly))
        .toString();
  }
}

class CalendarBuilder implements Builder<Calendar, CalendarBuilder> {
  _$Calendar _$v;

  String _id;
  String get id => _$this._id;
  set id(String id) => _$this._id = id;

  String _name;
  String get name => _$this._name;
  set name(String name) => _$this._name = name;

  bool _readOnly;
  bool get readOnly => _$this._readOnly;
  set readOnly(bool readOnly) => _$this._readOnly = readOnly;

  CalendarBuilder();

  CalendarBuilder get _$this {
    if (_$v != null) {
      _id = _$v.id;
      _name = _$v.name;
      _readOnly = _$v.readOnly;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Calendar other) {
    if (other == null) {
      throw new ArgumentError.notNull('other');
    }
    _$v = other as _$Calendar;
  }

  @override
  void update(void Function(CalendarBuilder) updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Calendar build() {
    final _$result =
        _$v ?? new _$Calendar._(id: id, name: name, readOnly: readOnly);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
