package com.rescomms.device_calendar_extended.devicecalendar.models

import com.rescomms.device_calendar_extended.devicecalendar.common.DayOfWeek
import com.rescomms.device_calendar_extended.devicecalendar.common.RecurrenceFrequency


class RecurrenceRule(val recurrenceFrequency : RecurrenceFrequency) {
    var totalOccurrences: Int? = null
    var interval: Int? = null
    var endDate: Long? = null
    var daysOfTheWeek: MutableList<DayOfWeek>? = null
    var daysOfTheMonth: MutableList<Int>? = null
    var monthsOfTheYear: MutableList<Int>? = null
    var weeksOfTheYear: MutableList<Int>? = null
    var setPositions: MutableList<Int>? = null
}
