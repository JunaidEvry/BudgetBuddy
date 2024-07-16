<cfinclude template="../headerLibraries.cfm"/>
	<div class="pagetitle d-flex flex-row align-items-start justify-content-between mt-3 mb-1">
	  <div>
		<h1>User Settings</h1>
		<nav>
		  <ol class="breadcrumb">
			<li class="breadcrumb-item"><a href="../index.cfm">Home</a></li>
			<li class="breadcrumb-item active">User Settings</li>
		  </ol>
		</nav>
	  </div>
	</div>

	<div class="col-lg-6">

	  <form id="userSettingsForm">
		<div id="alertmessage" class="alert" style="display:none;"></div>
		<div class="alert alert-info" id="quickNote" style="display:none;">
		  Note: Changes will take effect after you log out and log back in.
		</div>
		<!-- Theme Selection -->
		<div class="form-group mb-3" data-bs-toggle="tooltip" data-bs-placement="right" title="Select your preferred theme for the application interface.">
		  <label>Theme</label><br>
		  <div class="form-check form-check-inline">
			  <input class="form-check-input" type="radio" name="theme" id="lightTheme" value="light" 
			  <cfif StructKeyExists(session,"userSettings") and StructKeyExists(session.userSettings, "theme") and session.usersettings.theme eq "light">checked</cfif>>
			  <label class="form-check-label" for="lightTheme">Light</label>
		  </div>
		  <div class="form-check form-check-inline">
			  <input class="form-check-input" type="radio" name="theme" id="darkTheme" value="dark" 
			  <cfif StructKeyExists(session,"userSettings") and StructKeyExists(session.userSettings, "theme") and session.usersettings.theme eq "dark">checked</cfif>>
			  <label class="form-check-label" for="darkTheme">Dark</label>
		  </div>
		</div>
	  	<!-- Time Zone Selection -->
		<div class="form-group mb-3" data-bs-toggle="tooltip" data-bs-placement="right" title="Set your preferred time zone for accurate time display.">
		  <label for="timezoneSelect">Time Zone</label>
			<select class="form-control" id="timezoneSelect" name="timezone">
				<!-- Africa -->
				<option value="Africa/Cairo">Africa/Cairo</option>
				<option value="Africa/Johannesburg">Africa/Johannesburg</option>
				<option value="Africa/Lagos">Africa/Lagos</option>
				
				<!-- America -->
				<option value="America/Los_Angeles">America/Los_Angeles (PST)</option>
				<option value="America/Denver">America/Denver (MST)</option>
				<option value="America/Chicago">America/Chicago (CST)</option>
				<option value="America/New_York">America/New_York (EST)</option>
				<option value="America/Sao_Paulo">America/Sao_Paulo</option>
				
				<!-- Asia -->
				<option value="Asia/Shanghai">Asia/Shanghai</option>
				<option value="Asia/Tokyo">Asia/Tokyo</option>
				<option value="Asia/Culcutta" selected>Asia/Kolkata</option>
				<option value="Asia/Dubai">Asia/Dubai</option>
				
				<!-- Australia -->
				<option value="Australia/Sydney">Australia/Sydney</option>
				<option value="Australia/Melbourne">Australia/Melbourne</option>
				<option value="Australia/Brisbane">Australia/Brisbane</option>
				
				<!-- Europe -->
				<option value="Europe/London">Europe/London</option>
				<option value="Europe/Berlin">Europe/Berlin</option>
				<option value="Europe/Paris">Europe/Paris</option>
				<option value="Europe/Moscow">Europe/Moscow</option>
				
				<!-- Pacific -->
				<option value="Pacific/Auckland">Pacific/Auckland</option>
				<option value="Pacific/Honolulu">Pacific/Honolulu</option>
			</select>
		</div>
		<!-- Preferred Language Selection -->
		<div class="form-group mb-3" data-bs-toggle="tooltip" data-bs-placement="right" title="Choose your preferred language for the application.">
		  <label for="languageSelect">Preferred Language</label>
			<select class="form-control" id="languageSelect" name="language">
				<option value="en">English</option>
				<!-- Add more languages as needed -->
			</select>
		</div>

		<!-- Date Format Selection -->
		<div class="form-group mb-3" data-bs-toggle="tooltip" data-bs-placement="right" title="Select your preferred date format.">
		  <label for="dateFormatSelect">Date Format</label>
			<select class="form-control" id="dateFormatSelect" name="dateFormat">
				<option value="mm/dd/yyyy">MM/DD/YYYY</option>
				<option value="dd/mm/yyyy">DD/MM/YYYY</option>
				<option value="yyyy/mm/dd">YYYY/MM/DD</option>
			</select>
		</div>

		<!-- Currency Type Selection -->
		<div class="form-group mb-3" data-bs-toggle="tooltip" data-bs-placement="right" title="Choose your preferred currency for transactions.">
		  <label for="currencySelect">Currency Type</label>
			<select class="form-control" id="currencySelect" name="currency">
				<option value="$">$ - US Dollar (USD)</option>
				<option value="USD">$ - US Dollar</option>
				<option value="EUR">€ - Euro</option>
				<option value="GBP">£ - British Pound</option>
				<option value="INR" selected>₹ - Indian Rupee</option>
				<option value="JPY">¥ - Japanese Yen</option>
				<option value="CAD">$ - Canadian Dollar</option>
				<option value="AUD">$ - Australian Dollar</option>
				<option value="CHF">CHF - Swiss Franc</option>
				<option value="CNY">¥ - Chinese Yuan</option>
				<option value="HKD">$ - Hong Kong Dollar</option>
				<option value="NZD">$ - New Zealand Dollar</option>
				<option value="SGD">$ - Singapore Dollar</option>
				<option value="KRW">₩ - South Korean Won</option>
				<option value="ZAR">R - South African Rand</option>
				<option value="BRL">R$ - Brazilian Real</option>
				<option value="RUB">₽ - Russian Ruble</option>
				<option value="SEK">kr - Swedish Krona</option>
				<option value="NOK">kr - Norwegian Krone</option>
				<option value="DKK">kr - Danish Krone</option>
				<option value="MYR">RM - Malaysian Ringgit</option>
				<option value="THB">฿ - Thai Baht</option>
				<option value="IDR">Rp - Indonesian Rupiah</option>
				<option value="PHP">₱ - Philippine Peso</option>
				<option value="VND">₫ - Vietnamese Dong</option>
				<option value="SAR">﷼ - Saudi Riyal</option>
				<option value="AED">د.إ - UAE Dirham</option>
				<option value="TRY">₺ - Turkish Lira</option>
				<option value="MXN">$ - Mexican Peso</option>
				<option value="ARS">$ - Argentine Peso</option>
			</select>
		</div>

		<!-- Submit Button -->
		<div class="form-group text-center">
			<button type="submit" class="btn btn-primary" id="saveBtn">Save Settings</button>
		</div>
	</form>
	</div>
	<script>
	</script>
	<script src="../assets/js/userSetting.js"></script>
	<cfinclude template="../footerLibraries.cfm"/>
