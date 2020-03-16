package com.rescomms.device_calendar_extended.devicecalendar

import com.google.gson.*
import com.rescomms.device_calendar_extended.devicecalendar.common.RecurrenceFrequency
import java.lang.reflect.Type

class RecurrenceFrequencySerializer: JsonSerializer<RecurrenceFrequency> {
    override fun serialize(src: RecurrenceFrequency?, typeOfSrc: Type?, context: JsonSerializationContext?): JsonElement {
        if(src != null) {
            return JsonPrimitive(src.ordinal)
        }
        return JsonObject()
    }

}