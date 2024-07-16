$(document).ready(function() {
	$('[data-bs-toggle="tooltip"]').tooltip({
		delay: { "show": 0, "hide": 5000 },
		template: '<div class="tooltip" role="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
	  }).on('shown.bs.tooltip', function() {
		var $this = $(this);
		setTimeout(function() {
		  $this.tooltip('hide');
		}, 5000);
	  });
	// Fetch existing settings on page load
	$.ajax({
		url: '../cfc/controllers/userSettingsController.cfc?method=getUserSettings',
		method: 'GET',
		success: function(response) {
			var result = JSON.parse(response);
			if (result.success) {
				var settings = result.settings;
				$('input[name="theme"][value="' + settings.theme + '"]').prop('checked', true);
				$('#timezoneSelect').val(settings.timezone);
				$('#languageSelect').val(settings.language);
				$('#dateFormatSelect').val(settings.dateFormat);
				$('#currencySelect').val(settings.currency);
			} else {
				$('input[name="theme"][value="' + application.settings.theme + '"]').prop('checked', true);
				$('#timezoneSelect').val(application.settings.timezone);
				$('#languageSelect').val(application.settings.language);
				$('#dateFormatSelect').val(application.settings.dateFormat);
				$('#currencySelect').val(application.settings.currency);
			}
		},
		error: function(xhr, status, error) {
			$("#errorMessage").text("Error fetching user settings"+error).show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
			}, 1000);
		}
	});
	
	// Handle form submission
	$('#userSettingsForm').on('submit', function(event) {
		event.preventDefault();

		var settings = {
			theme: $('input[name="theme"]:checked').val(),
			timezone: $('#timezoneSelect').val(),
			language: $('#languageSelect').val(),
			dateFormat: $('#dateFormatSelect').val(),
			currency: $('#currencySelect').val()
		};

		$.ajax({
			url: '../cfc/controllers/userSettingsController.cfc?method=updateUserSettings',
			method: 'POST',
			data: settings,
			success: function(response) {
				var result = JSON.parse(response);
				if (result.success) {
					$('#alertmessage').removeClass('alert-dander').addClass('alert-success').text("UserSettings updated successfully").show();
					setTimeout(() => {
						$('#alertmessage').removeClass('alert-dander').addClass('alert-success').text("UserSettings updated successfully").hide();
						$("#quickNote").show();
					}, 2000);  
					setTimeout(() => {
						$("#quickNote").hide();
					}, 6000);
				        }
						else {
						$('#alertmessage').addClass('alert-dander').removeClass('alert-success').text("UserSettings cannot be updated,Please try again after sometime").show();
						setTimeout(() => {
							$('#alertmessage').removeClass('alert-dander').addClass('alert-success').text("UserSettings cannot be updated,Please try again after sometime" ).hide();
						
						}, 2000);           }
			},
			error: function(xhr, status, error) {
				$("#errorMessage").text("Error updating user settings"+error).show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
	
			}
		});
	});
});