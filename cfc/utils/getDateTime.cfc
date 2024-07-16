component output="false"{
    /*
    Function used to return the formatted datetime that is used toStore in DB according to the
    Timezone preferred By user in userSetting
    */
    public string function getTimeZoneDate() {
        // Get the user's timezone from the session\
        var selectedTimeZone = session.userSettings.timezone; 
        currentDate = now();
        timeZone = createObject("java", "java.util.TimeZone").getTimeZone(selectedTimeZone);
        rawOffsetMillis = timeZone.getRawOffset();
        isDST = timeZone.inDaylightTime(currentDate);
        if (isDST) {
            // Add daylight saving time offset in milliseconds
            dstOffsetMillis = timeZone.getDSTSavings();
            rawOffsetMillis += dstOffsetMillis;
        }
         // Convert the offset from milliseconds to hours
         offsetHours = rawOffsetMillis / 3600000;    
         // Format as UTC±[offset]
         utcOffset = "UTC" & (offsetHours lt 0 ? offsetHours : "+" & offsetHours);
         // Convert the current date and time to the selected time zone
         // Adjust date based on the calculated offset
         offsetMinutes = rawOffsetMillis / 60000;
         convertedDate = dateAdd("n", offsetMinutes, currentDate);
         formattedDate = dateFormat(convertedDate, "MM/dd/yyyy") & " " & timeFormat(convertedDate, "hh:mm:ss tt");
         return formattedDate;
    }
}