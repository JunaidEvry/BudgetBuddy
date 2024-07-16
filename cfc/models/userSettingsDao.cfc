component output="false"{
	 

		// Method to get user settings by user ID
		public struct function getUserSettingsByUserID(required numeric userID) {
			var result = { success = false, settings = {}, message = "" };
	
			try {
				var settingsQuery = new Query();
				settingsQuery.setDatasource("FinanceManager");
				settingsQuery.setSQL("
					SELECT s.SettingName, us.SettingValue
					FROM UserSettings us
					JOIN Settings s ON us.SettingID = s.SettingID
					WHERE us.UserID = :userID
				");
				settingsQuery.addParam(name="userID", value=userID, cfsqltype="cf_sql_integer");
	
				var queryResult = settingsQuery.execute().getResult();
	
				if (queryResult.recordCount > 0) {
					var settings = {};
					for (var row in queryResult) {
						settings[row.SettingName] = row.SettingValue;
					}
					result.success = true;
					result.settings = settings;
				} else {
					result.message = "No settings found for user.";
				}
	
			} catch (any e) {
				result.message = "Error fetching user settings: " & e.message;
				writeLog(file="Database", text="Error fetching user settings: " & e.message & "; Details: " & e.detail);
			}
	
			return result;
		}
	
		// Method to update user settings
		public void function updateUserSettings(required numeric userID, required struct settings) {
			try {
				var settingNames = [
					"theme",
					"timezone",
					"language",
					"dateFormat",
					"currency"
				];
				// Get TimeZone based Date from the utils
				var getDateTime = new cfc.utils.getDateTime();
				var formattedDate = getDateTime.getTimeZoneDate();
	
				for (var settingName in settingNames) {
					var settingValue = settings[settingName];
					
					var query = new Query();
					
					query.setSQL("
						MERGE INTO UserSettings AS target
						USING (SELECT :userID AS UserID, :settingName AS SettingName) AS source
						ON (target.UserID = source.UserID AND target.SettingID = (SELECT SettingID FROM Settings WHERE SettingName = :settingName))
						WHEN MATCHED THEN 
							UPDATE SET SettingValue = :settingValue, UpdatedAt = :formattedDate
						WHEN NOT MATCHED THEN 
							INSERT (UserID, SettingID, SettingValue, CreatedAt, UpdatedAt)
							VALUES (:userID, (SELECT SettingID FROM Settings WHERE SettingName = :settingName), :settingValue, :formattedDate, :formattedDate);
					");
					query.addParam(name="userID", value=userID, cfsqltype="cf_sql_integer");
					query.addParam(name="settingName", value=settingName, cfsqltype="cf_sql_varchar");
					query.addParam(name="settingValue", value=settingValue, cfsqltype="cf_sql_varchar");
					query.addParam(name="formattedDate", value=formattedDate, cfsqltype="cf_sql_varchar");
	
					query.execute();
				}
			} catch (any e) {
				
				writeLog(file="Database", text="Error fetching user settings: " & e.message & "; Details: " & e.detail);
			}
		 
		}
	}
	