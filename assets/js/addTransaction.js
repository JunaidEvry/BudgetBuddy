$(document).ready(function() {
	var today = new Date().toISOString().split('T')[0];
	//fetches Data from userSettings
	$.ajax({
		url: './cfc/controllers/userSettingsController.cfc?method=getUserSettings',
		method: 'GET',
		dataType: 'json',
		success: function(response) {	
		  var currency = response.settings.currency;
		  var currentDate = new Date().toISOString().split('T')[0]; // Get current date in YYYY-MM-DD format
		  showAddTransactionModal(currentDate, currency);
		},
		error: function(xhr, status, error) {
			$("#errorMessage").text("Error fetching user settings").show();
			setTimeout(() => {
				$("#errorMessage").fadeOut(1000);
			}, 1000);
		}
	});
	loadRecentTransactionTable();
	loadCharts();
	// Disable category dropdown initially
	$('#transactionCategory').prop('disabled', true);
	// Set the max date for the date input to today
	var today = new Date().toISOString().split('T')[0];
	$('#transactionDate').attr('max', today);

	callMe();
});

/*
Loads Recent transaction
*/
function loadRecentTransactionTable(){
	Handlebars.registerHelper('incrementIndex', function(value) {
		return parseInt(value) + 1;
	  });
	$.ajax({
		url: './cfc/controllers/transactionController.cfc?method=getRecentTransactions',
		method: 'GET',
		dataType: 'json',
		success: function(response) {
			var result = response;
			if (result.success) {
				var transactions = result.transactions;
				$.get('./templates/recentTransactions.hbs', function(templateData) {
					var template = Handlebars.compile(templateData);
					var currency=result.currency;
					var html = template({
					  currency: currency,
					  transactions: transactions
					});
					$('#recentTransactionsPlaceholder').html(html);
					$('#recentTransactionTable').DataTable();
				  });
			}else{
				$("#errorMessage").text("Failed to fetch transactions" ).show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
			}
		},
		error: function(xhr, status, error) {
			$("#errorMessage").text("Failed to fetch transactions").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
		}
	});
}

/*
Validates add transaction Form
*/
function validateForm() {
	var isValid = true;
	var date = $('#transactionDate').val();
	if (!date) {
		isValid = false;
		$('#transactionDate').addClass('is-invalid');
	} else {
		$('#transactionDate').removeClass('is-invalid');
	}
	// Validate type (not null)
	var type = $('#transactionType').val();
	if (!type) {
		isValid = false;
		$('#transactionType').addClass('is-invalid');
	} else {
		$('#transactionType').removeClass('is-invalid');
	}
	// Validate category (not null)
	var category = $('#transactionCategory').val();
	if (!category) {
		isValid = false;
		$('#transactionCategory').addClass('is-invalid');
	} else {
		$('#transactionCategory').removeClass('is-invalid');
	}
	// Validate amount (only numbers)
	var amount = $('#transactionAmount').val();
	if (!amount || isNaN(amount) || amount <= 0) {
		isValid = false;
		$('#transactionAmount').addClass('is-invalid');
	} else {
		$('#transactionAmount').removeClass('is-invalid');
	}
	// Validate description (only letters and spaces)
	var description = $('#transactionDescription').val();
	var descriptionRegex = /^[A-Za-z\s]+$/;
	if (!description || !descriptionRegex.test(description)) {
		isValid = false;
		$('#transactionDescription').addClass('is-invalid');
	} else {
		$('#transactionDescription').removeClass('is-invalid');
	}
	// Validate receipt (optional, but only pdf/img files allowed)
	var receipt = $('#transactionReceipt').val();
	if (receipt) {
		var allowedExtensions = /(\.jpg|\.jpeg|\.png|\.pdf)$/i;
		if (!allowedExtensions.exec(receipt)) {
			isValid = false;
			$('#transactionReceipt').addClass('is-invalid');
		} else {
			$('#transactionReceipt').removeClass('is-invalid');
		}
	} else {
		$('#transactionReceipt').removeClass('is-invalid');
	}

	return isValid;

}
/*
Load the charts
*/
function loadCharts(){
	$.ajax({
		url: './cfc/controllers/transactionController.cfc?method=getExpenseData',
		method: 'GET',
		dataType: 'json',
		success: function(response) {
			var results=response.DATA;
			if (response.SUCCESS) {
			 
				var expenseData = $.map(results.DATA, function(item) {
			 
					return parseFloat(item[1]);
				});
				var expenseLabels = $.map(results.DATA, function(item) {
					return item[0];
				});
			 
				new ApexCharts(document.querySelector("#pieChart"), {
					series: expenseData,
					chart: {
						height: 350,
						type: 'pie',
						toolbar: {
							show: false
						}
					},
					labels: expenseLabels
				}).render();
			} else {
				$("#errorMessage").text("Failed to  Load charts").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
			}
		},
		error: function(error) {
			$("#errorMessage").text("Failed to  Load charts").show();
			setTimeout(() => {
				$("#errorMessage").fadeOut(1000);
			}, 1000);
		}
	});

	// Fetch income data
	$.ajax({
		url: './cfc/controllers/transactionController.cfc?method=getIncomeData',
		method: 'GET',
		dataType: 'json',
		success: function(response) {
			var results=response.DATA;
			if (response.SUCCESS) {
		 
				var incomeData = $.map(results.DATA, function(item) {
					return parseFloat(item[1]);
				});
				var incomeLabels = $.map(results.DATA, function(item) {
					return item[0];
				});
				new ApexCharts(document.querySelector("#pieChart2"), {
					series: incomeData,
					chart: {
						height: 350,
						type: 'pie',
						toolbar: {
							show: false
						}
					},
					labels: incomeLabels
				}).render();
			} else {
				$("#errorMessage").text("Failed to  Load charts").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
			}
		},
		error: function(error) {
			$("#errorMessage").text("Failed to  Load charts").show();
			setTimeout(() => {
				$("#errorMessage").fadeOut(1000);
			}, 1000);
		}
	});
}
/*
Submit add transaction
*/
$(document).on('click', '#addTransactionBtn', function(event) {
	event.preventDefault(); 
	var date = $('#transactionDate').val();
    var type = $('#transactionType').val();
    var category = $('#transactionCategory').val();
    var amount = $('#transactionAmount').val();
    var description = $('#transactionDescription').val();
    var receipt = $('#transactionReceipt').val();

    // Validate the form
    var isValid = validateForm(date, type, category, amount, description, receipt);
	
	if (isValid) {
		var formData = new FormData($('#addTransactionForm')[0]); // Create a FormData object from the form 
		$.ajax({
			url: './cfc/controllers/transactionController.cfc?method=addTransaction',
			method: 'POST',
			data: formData,
			contentType: false, // Important: Do not set content type to allow multipart/form-data
			processData: false, // Important: Prevent jQuery from processing the data
			success: function(response) {
				var result = JSON.parse(response);
				if (result.success) {
					loadRecentTransactionTable();
					loadCharts();
					$('#message').removeClass('alert-danger').addClass('alert-success').text(result.message).show();
						setTimeout(() => {
						$('#message').removeClass('alert-danger').addClass('alert-success').text(result.message).hide();
						$('#addTransactionForm')[0].reset();
						$('#verticalycentered').modal('hide');
						}, 2000);		
				} else {
					$('#message').removeClass('alert-success').addClass('alert-danger').text(result.message).show();
				}
			},
			error: function(xhr, status, error) {
				$("#errorMessage").text("Failed to Add transactions").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
			}
		});
	}
});

// When transaction type is selected
$(document).on('change', '#transactionType', function() {
	var type = $(this).val();
	if (type === 'Income' || type === 'Expense') {
		// Enable category dropdown
		$('#transactionCategory').prop('disabled', false);
		// AJAX call to fetch categories based on type
		$.ajax({
			url: './cfc/controllers/categoryController.cfc?method=getCategoriesByType',
			method: 'POST',
			data: { 
				type: type
			},
			success: function(response) {
				var result = JSON.parse(response);
				// Clear existing options
				$('#transactionCategory').empty();
				// Load the Handlebars template asynchronously
				$.get('./templates/categoryOptions.hbs', function(templateData) {
					// Compile Handlebars template
					var template = Handlebars.compile(templateData);
					// Render categories using the template
					var html = template(result);
					// Append options to select
					$('#transactionCategory').append(html);
				});
			},
			error: function(xhr, status, error) {
				$("#errorMessage").text("Failed to fetch Categories").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
			}
		});
	} else {
		// If no type selected, disable and reset category dropdown
		$('#transactionCategory').prop('disabled', true);
		$('#transactionCategory').empty().append('<option value="" disabled selected>Select type first</option>');
	}
});

/*
Render the Modal
*/
function showAddTransactionModal(currentDate, currency) {
	Handlebars.registerHelper('eq', function(a, b) {
		if (a === b) {
		  return true;
		}
		return false;
	});
	// Load the Handlebars template asynchronously
	$.get('./templates/transactionForm.hbs', function(templateData) {
	// Compile Handlebars template
	var template = Handlebars.compile(templateData);
	var form="Add";
	// Render the modal content using the template
	var html = template({
	currentDate: currentDate,
	currency: currency,
	form:form
	});
	// Inject the rendered HTML into the placeholder and show the modal
	$('#modalPlaceholder').html(html);	  
	});
}