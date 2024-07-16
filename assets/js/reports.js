$(document).ready(function() {
	// Get the current date in YYYY-MM-DD format
	var currentDate = new Date().toISOString().split('T')[0];

	// Set the max attribute for the From Date input
	$('#floatingFromDate').attr('max', currentDate);

	// Set the max attribute for the To Date input
	$('#floatingToDate').attr('max', currentDate);

	// Update the min attribute for the To Date input when From Date changes
	$('#floatingFromDate').on('change', function() {
		var fromDate = $(this).val();
		$('#floatingToDate').attr('min', fromDate);
	});
});




$('#reportFormBtn').click(function(event) {
	event.preventDefault(); // Prevent the default form submission

	// Gather form data
	var fromDate = $('#floatingFromDate').val();
	var toDate = $('#floatingToDate').val();
	var fileType = $('#floatingType').val();

	if (!fromDate || !toDate) {
		$('#reportMessage').removeClass('alert-success').addClass('alert-danger').text('Both From Date and To Date are required.').show();
		return; // Exit the function if dates are not filled out
	}
	// Send AJAX request to generate the report
	$.ajax({
		url: '../cfc/controllers/reportsController.cfc?method=generateReport',
		method: 'POST',
		data: {
			fromDate: fromDate,
			toDate: toDate,
			fileType: fileType
		},
		success: function(response) {
			var result = JSON.parse(response);
			if (result.success) {
				window.open(result.fileURL, '_blank'); 
			} else {
				$('#reportMessage').removeClass('alert-success').addClass('alert-danger').text('Error Generating Report. Please try again.').show();
			}
		},
		error: function(xhr, status, error) {
			$('#reportMessage').removeClass('alert-success').addClass('alert-danger').text('Error Generating Report. Please try again.').show();
		}
	});
});