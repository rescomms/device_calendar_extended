import 'package:device_calendar_extended/models.dart';
import 'package:device_calendar_extended/device_calendar_extended.dart';
import 'event_attendees.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../date_time_picker.dart';
import '../widgets/days_of_the_week_form_entry.dart';
import 'event_reminders.dart';

enum RecurrenceRuleEndType { MaxOccurrences, SpecifiedEndDate }

class CalendarEventPage extends StatefulWidget {
  final Calendar _calendar;
  final Event _event;

  CalendarEventPage(this._calendar, [this._event]);

  @override
  _CalendarEventPageState createState() {
    return _CalendarEventPageState(_calendar, _event);
  }
}

class _CalendarEventPageState extends State<CalendarEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Calendar _calendar;

  Event _event;
  DeviceCalendarExtended _deviceCalendarPlugin;

  DateTime _startDate;
  TimeOfDay _startTime;

  DateTime _endDate;
  TimeOfDay _endTime;

  bool _autovalidate = false;
  bool _isRecurringEvent = false;
  RecurrenceRuleEndType _recurrenceRuleEndType;

  List<DayOfTheWeek> _daysOfTheWeek = List<DayOfTheWeek>();
  List<int> _daysOfTheMonth = List<int>();
  List<int> _monthsOfTheYear = List<int>();
  List<int> _weeksOfTheYear = List<int>();
  List<int> _setPositions = List<int>();
  List<int> _validDaysOfTheMonth = List<int>();
  List<int> _validMonthsOfTheYear = List<int>();
  List<int> _validWeeksOfTheYear = List<int>();
  List<Attendee> _attendees = List<Attendee>();
  List<Reminder> _reminders = List<Reminder>();
  int _totalOccurrences;
  int _interval;
  DateTime _recurrenceEndDate;
  TimeOfDay _recurrenceEndTime;

  RecurrenceFrequency _recurrenceFrequency = RecurrenceFrequency.Daily;

  _CalendarEventPageState(this._calendar, this._event) {
    _deviceCalendarPlugin = DeviceCalendarExtended();
    for (var i = -31; i <= -1; i++) {
      _validDaysOfTheMonth.add(i);
    }
    for (var i = 1; i <= 31; i++) {
      _validDaysOfTheMonth.add(i);
    }
    for (var i = 1; i <= 12; i++) {
      _validMonthsOfTheYear.add(i);
    }
    for (var i = -53; i <= -1; i++) {
      _validWeeksOfTheYear.add(i);
    }
    for (var i = 1; i <= 53; i++) {
      _validWeeksOfTheYear.add(i);
    }
    _attendees = List<Attendee>();
    _reminders = List<Reminder>();
    if (this._event == null) {
      _startDate = DateTime.now();
      _endDate = DateTime.now().add(Duration(hours: 1));
      _event = Event(this._calendar.id, start: _startDate, end: _endDate);
      _recurrenceEndDate = _endDate;
    } else {
      _startDate = _event.start;
      _endDate = _event.end;
      _isRecurringEvent = _event.recurrenceRule != null;
      if (_event.attendees.isNotEmpty) {
        _attendees.addAll(_event.attendees);
      }
      if (_event.reminders.isNotEmpty) {
        _reminders.addAll(_event.reminders);
      }
      if (_isRecurringEvent) {
        _interval = _event.recurrenceRule.interval;
        _totalOccurrences = _event.recurrenceRule.totalOccurrences;
        _recurrenceFrequency = _event.recurrenceRule.recurrenceFrequency;
        if (_totalOccurrences != null) {
          _recurrenceRuleEndType = RecurrenceRuleEndType.MaxOccurrences;
        }
        if (_event.recurrenceRule.endDate != null) {
          _recurrenceRuleEndType = RecurrenceRuleEndType.SpecifiedEndDate;
          _recurrenceEndDate = _event.recurrenceRule.endDate;
          _recurrenceEndTime = TimeOfDay.fromDateTime(_recurrenceEndDate);
        }
        _daysOfTheWeek =
            _event.recurrenceRule.daysOfTheWeek ?? List<DayOfTheWeek>();
        _daysOfTheMonth = _event.recurrenceRule.daysOfTheMonth ?? List<int>();
        _monthsOfTheYear = _event.recurrenceRule.monthsOfTheYear ?? List<int>();
        _weeksOfTheYear = _event.recurrenceRule.weeksOfTheYear ?? List<int>();
        _setPositions = _event.recurrenceRule.setPositions ?? List<int>();
      }
    }

    _startTime = TimeOfDay(hour: _startDate.hour, minute: _startDate.minute);
    _endTime = TimeOfDay(hour: _endDate.hour, minute: _endDate.minute);
    if (_recurrenceEndDate != null) {
      _recurrenceEndTime = TimeOfDay(
          hour: _recurrenceEndDate.hour, minute: _recurrenceEndDate.minute);
    }
  }

  void printAttendeeDetails(Attendee attendee) {
    print(
        'attendee name: ${attendee.name}, email address: ${attendee.emailAddress}');
    print(
        'ios specifics - status: ${attendee.iosAttendeeDetails?.attendanceStatus}, role:  ${attendee.iosAttendeeDetails?.role}');
    print(
        'android specifics - status ${attendee.androidAttendeeDetails?.attendanceStatus}, is required: ${attendee.androidAttendeeDetails?.isRequired}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(_event.eventId?.isEmpty ?? true
            ? 'Create event'
            : 'Edit event ${_event.title}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Form(
              autovalidate: _autovalidate,
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      key: Key('titleField'),
                      initialValue: _event.title,
                      decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Meeting with Gloria...'),
                      validator: _validateTitle,
                      onSaved: (String value) {
                        _event.title = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      initialValue: _event.notes,
                      decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Remember to buy flowers...'),
                      onSaved: (String value) {
                        _event.notes = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DateTimePicker(
                      labelText: 'From',
                      selectedDate: _startDate,
                      selectedTime: _startTime,
                      selectDate: (DateTime date) {
                        setState(() {
                          _startDate = date;
                          _event.start =
                              _combineDateWithTime(_startDate, _startTime);
                        });
                      },
                      selectTime: (TimeOfDay time) {
                        setState(
                          () {
                            _startTime = time;
                            _event.start =
                                _combineDateWithTime(_startDate, _startTime);
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: DateTimePicker(
                      labelText: 'To',
                      selectedDate: _endDate,
                      selectedTime: _endTime,
                      selectDate: (DateTime date) {
                        setState(
                          () {
                            _endDate = date;
                            _event.end =
                                _combineDateWithTime(_endDate, _endTime);
                          },
                        );
                      },
                      selectTime: (TimeOfDay time) {
                        setState(
                          () {
                            _endTime = time;
                            _event.end =
                                _combineDateWithTime(_endDate, _endTime);
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      initialValue: _event.location,
                      decoration: const InputDecoration(
                          labelText: 'Location', hintText: 'Sydney, Australia'),
                      onSaved: (String value) {
                        _event.location = value;
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      List<Attendee> result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventAttendeesPage(_attendees)));
                      if (result == null) {
                        return;
                      }
                      _attendees = result;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10.0,
                          children: [
                            Icon(Icons.people),
                            if (_attendees.isEmpty) Text('Add people'),
                            for (var attendee in _attendees)
                              Text('${attendee.emailAddress};')
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      List<Reminder> result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  EventRemindersPage(_reminders)));
                      if (result == null) {
                        return;
                      }
                      _reminders = result;
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 10.0,
                          children: [
                            Icon(Icons.alarm),
                            if (_reminders.isEmpty) Text('Add reminders'),
                            for (var reminder in _reminders)
                              Text('${reminder.minutes} minutes before; ')
                          ],
                        ),
                      ),
                    ),
                  ),
                  CheckboxListTile(
                    value: _isRecurringEvent,
                    title: Text('Is recurring'),
                    onChanged: (isChecked) {
                      setState(() {
                        _isRecurringEvent = isChecked;
                      });
                    },
                  ),
                  if (_isRecurringEvent) ...[
                    ListTile(
                      leading: Text('Frequency'),
                      trailing: DropdownButton<RecurrenceFrequency>(
                        onChanged: (selectedFrequency) {
                          setState(() {
                            _recurrenceFrequency = selectedFrequency;
                          });
                        },
                        value: _recurrenceFrequency,
                        items: RecurrenceFrequency.values
                            .map((f) => DropdownMenuItem(
                                  value: f,
                                  child: _recurrenceFrequencyToText(f),
                                ))
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        initialValue: _interval?.toString(),
                        decoration: const InputDecoration(
                            labelText: 'Interval between events',
                            hintText: '1'),
                        keyboardType: TextInputType.number,
                        validator: _validateInterval,
                        onSaved: (String value) {
                          _interval = int.tryParse(value);
                        },
                      ),
                    ),
                    if (_recurrenceFrequency == RecurrenceFrequency.Weekly ||
                        _recurrenceFrequency == RecurrenceFrequency.Monthly ||
                        _recurrenceFrequency == RecurrenceFrequency.Yearly)
                      DaysOfTheWeekFormEntry(daysOfTheWeek: _daysOfTheWeek),
                    if (_recurrenceFrequency ==
                        RecurrenceFrequency.Monthly) ...[
                      ListTile(
                        leading: Text('Days of the month'),
                        trailing: DropdownButton<int>(
                          onChanged: (value) {
                            setState(() {
                              _daysOfTheMonth.clear();
                              _daysOfTheMonth.add(value);
                            });
                          },
                          value: _daysOfTheMonth.isEmpty
                              ? null
                              : _daysOfTheMonth[0],
                          items: _validDaysOfTheMonth
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(
                                      d.toString(),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                    if (_recurrenceFrequency == RecurrenceFrequency.Yearly) ...[
                      ListTile(
                        leading: Text('Weeks of the year'),
                        trailing: DropdownButton<int>(
                          onChanged: (value) {
                            setState(() {
                              _weeksOfTheYear.clear();
                              _weeksOfTheYear.add(value);
                            });
                          },
                          value: _weeksOfTheYear.isEmpty
                              ? null
                              : _weeksOfTheYear[0],
                          items: _validWeeksOfTheYear
                              .map((w) => DropdownMenuItem(
                                    value: w,
                                    child: Text(
                                      w.toString(),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      ListTile(
                        leading: Text('Months of the year'),
                        trailing: DropdownButton<int>(
                          onChanged: (value) {
                            setState(() {
                              _monthsOfTheYear.clear();
                              _monthsOfTheYear.add(value);
                            });
                          },
                          value: _monthsOfTheYear.isEmpty
                              ? null
                              : _monthsOfTheYear[0],
                          items: _validMonthsOfTheYear
                              .map((m) => DropdownMenuItem(
                                    value: m,
                                    child: Text(
                                      m.toString(),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextFormField(
                        initialValue: _setPositions.isEmpty
                            ? null
                            : _setPositions.first.toString(),
                        decoration:
                            const InputDecoration(labelText: 'Set positions'),
                        keyboardType: TextInputType.number,
                        validator: _validateSetPositions,
                        onSaved: (String value) {
                          _setPositions.clear();
                          if (value == null || value.isEmpty) {
                            return;
                          }
                          _setPositions.add(int.parse(value));
                        },
                      ),
                    ),
                    ListTile(
                      leading: Text('Event ends'),
                      trailing: DropdownButton<RecurrenceRuleEndType>(
                        onChanged: (value) {
                          setState(() {
                            _recurrenceRuleEndType = value;
                          });
                        },
                        value: _recurrenceRuleEndType,
                        items: RecurrenceRuleEndType.values
                            .map((f) => DropdownMenuItem(
                                  value: f,
                                  child: _recurrenceRuleEndTypeToText(f),
                                ))
                            .toList(),
                      ),
                    ),
                    if (_recurrenceRuleEndType ==
                        RecurrenceRuleEndType.MaxOccurrences)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextFormField(
                          initialValue: _totalOccurrences?.toString(),
                          decoration: const InputDecoration(
                              labelText: 'Max occurrences', hintText: '1'),
                          keyboardType: TextInputType.number,
                          validator: _validateTotalOccurrences,
                          onSaved: (String value) {
                            _totalOccurrences = int.tryParse(value);
                          },
                        ),
                      ),
                    if (_recurrenceRuleEndType ==
                        RecurrenceRuleEndType.SpecifiedEndDate)
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: DateTimePicker(
                          labelText: 'Date',
                          selectedDate: _recurrenceEndDate,
                          selectedTime: _recurrenceEndTime,
                          selectDate: (DateTime date) {
                            setState(() {
                              _recurrenceEndDate = date;
                            });
                          },
                          selectTime: (TimeOfDay time) {
                            setState(() {
                              _recurrenceEndTime = time;
                            });
                          },
                        ),
                      ),
                  ],
                ],
              ),
            ),
            if (_event.eventId?.isNotEmpty ?? false)
              RaisedButton(
                key: Key('deleteEventButton'),
                textColor: Colors.white,
                color: Colors.red,
                child: Text('Delete'),
                onPressed: () async {
                  await _deviceCalendarPlugin.deleteEvent(
                      _calendar.id, _event.eventId);
                  Navigator.pop(context, true);
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: Key('saveEventButton'),
        onPressed: () async {
          final FormState form = _formKey.currentState;
          if (!form.validate()) {
            _autovalidate = true; // Start validating on every change.
            showInSnackBar('Please fix the errors in red before submitting.');
          } else {
            form.save();
            if (_isRecurringEvent) {
              _event.recurrenceRule = RecurrenceRule(_recurrenceFrequency,
                  interval: _interval,
                  totalOccurrences: _totalOccurrences,
                  endDate: _recurrenceRuleEndType ==
                          RecurrenceRuleEndType.SpecifiedEndDate
                      ? _combineDateWithTime(
                          _recurrenceEndDate, _recurrenceEndTime)
                      : null,
                  daysOfTheWeek: _daysOfTheWeek,
                  daysOfTheMonth: _daysOfTheMonth,
                  monthsOfTheYear: _monthsOfTheYear,
                  weeksOfTheYear: _weeksOfTheYear,
                  setPositions: _setPositions);
            }
            _event.attendees = _attendees;
            _event.reminders = _reminders;
            var createEventResult =
                await _deviceCalendarPlugin.createOrUpdateEvent(_event);
            if (createEventResult.isSuccess) {
              Navigator.pop(context, true);
            } else {
              showInSnackBar(createEventResult.errorMessages.join(' | '));
            }
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  Text _recurrenceFrequencyToText(RecurrenceFrequency recurrenceFrequency) {
    switch (recurrenceFrequency) {
      case RecurrenceFrequency.Daily:
        return Text('Daily');
      case RecurrenceFrequency.Weekly:
        return Text('Weekly');
      case RecurrenceFrequency.Monthly:
        return Text('Monthly');
      case RecurrenceFrequency.Yearly:
        return Text('Yearly');
      default:
        return Text('');
    }
  }

  Text _recurrenceRuleEndTypeToText(RecurrenceRuleEndType endType) {
    switch (endType) {
      case RecurrenceRuleEndType.MaxOccurrences:
        return Text('After a set number of times');
      case RecurrenceRuleEndType.SpecifiedEndDate:
        return Text('Continues until a specified date');
      default:
        return Text('');
    }
  }

  String _validateTotalOccurrences(String value) {
    if (value.isNotEmpty && int.tryParse(value) == null) {
      return 'Total occurrences needs to be a valid number';
    }
    return null;
  }

  String _validateSetPositions(String value) {
    if (value.isNotEmpty && int.tryParse(value) == null) {
      return 'Set position needs to be a valid number';
    }
    return null;
  }

  String _validateInterval(String value) {
    if (value.isNotEmpty && int.tryParse(value) == null) {
      return 'Interval needs to be a valid number';
    }
    return null;
  }

  String _validateTitle(String value) {
    if (value.isEmpty) {
      return 'Name is required.';
    }

    return null;
  }

  DateTime _combineDateWithTime(DateTime date, TimeOfDay time) {
    if (date == null && time == null) {
      return null;
    }
    final dateWithoutTime =
        DateTime.parse(DateFormat("y-MM-dd 00:00:00").format(date));
    return dateWithoutTime
        .add(Duration(hours: time.hour, minutes: time.minute));
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}
