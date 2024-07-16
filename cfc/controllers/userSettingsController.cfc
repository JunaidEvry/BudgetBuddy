component output="false" {

    /**
     * Fetches the user settings for the current user.
     * @return A JSON structure containing success status, the user settings, and a message.
     */
    remote struct function getUserSettings() returnFormat="json" {
        var result = { 
            "success" = false, 
            "settings" = {}, 
            "message" = "" 
        };

        try {
            // Get userID from session
            var userID = session.userID;

            // Create an instance of the userSettingsDAO
            var userSettingsDao = new cfc.models.userSettingsDao();

            // Call DAO to fetch user settings by userID
            var settingsResult = userSettingsDao.getUserSettingsByUserID(userID);

            if (settingsResult.success) {
                result.success = true;
                result.settings = settingsResult.settings;
            } else {
                result.message = settingsResult.message;
                
            }

        } catch (any e) {
            result.message = "Error fetching user settings: " & e.message;
            writeLog(file="Application", text="Error fetching user settings: " & e.message & "; Details: " & e.detail);
        }

        return (result);
    }

    /**
     * Updates the user settings for the current user.
     * @param theme (required) - The new theme setting.
     * @param timezone (required) - The new time zone setting.
     * @param language (required) - The new language setting.
     * @param dateFormat (required) - The new date format setting.
     * @param currency (required) - The new currency setting.
     * @return A JSON structure containing success status and a message.
     */
    remote struct function updateUserSettings(
        required string theme,
        required string timezone,
        required string language,
        required string dateFormat,
        required string currency
    ) returnFormat="json" {
        var result = { 
            "success" = false, 
            "message" = "" 
        };

        try {
            // Get userID from session
            var userID = session.userID;

            // Prepare settings data to be updated
            var settings = {
                theme = arguments.theme,
                timezone = arguments.timezone,
                language = arguments.language,
                dateFormat = arguments.dateFormat,
                currency = arguments.currency
            };

            // Create an instance of the userSettingsDAO
            var userSettingsDao = new cfc.models.userSettingsDao();

            // Call DAO to update user settings
            userSettingsDao.updateUserSettings(userID, settings);

            // Fetch the updated user settings
            getUserSettings();
            
            result.success = true;
        } catch (any e) {
            result.message = "Error updating user settings: " & e.message;
            writeLog(file="Application", text="Error updating user settings: " & e.message & "; Details: " & e.detail);
        }

        return (result);
    }

}
