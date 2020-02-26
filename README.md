# device_calendar_extended

Provides bindings to native device calendar (on iOS and Android), with the
capability to synchronise the calendar on background. Contrary to 
[device_calendar](https://pub.dev/packages/device_calendar), the iOS part
is done with ObjectiveC, so that the problems of missing Swift ABI (resulting
in large binary sizes due to embedding several versions of Flutter libraries)
can be avoided.


## Features

* TODO Synchronise selected calendar(s) periodically in the background, and invoke application on data change.
3-8-5-3-recurrence-rule.html) (RRULE part)
* TODO Lists device calendars
* TODO Creates/Retrieves/Updates/Deletes calendar events
* TODO Supports iCal [recurrence rules](https://icalendar.org/iCalendar-RFC-5545/

## Getting Started


This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

