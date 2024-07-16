$(document).ready(function() {
	loadTransactionTable();
	// Initialize DataTable
	$('#transactionListTable').DataTable();
	var today = new Date().toISOString().split('T')[0];
	$('#transactionDate').attr('max', today); 
	$.ajax({
		url: '../cfc/controllers/userSettingsController.cfc?method=getUserSettings',
		method: 'GET',
		dataType: 'json',
		success: function(response) {	
			var form="Edit";
			currency = response.settings.currency;
			var currentDate = new Date().toISOString().split('T')[0]; // Get current date in YYYY-MM-DD format
			showEditTransactionModal(currentDate, currency,form);
		},
		error: function(xhr, status, error) {
			$("#errorMessage").text("Error fetching user settings").show();
			setTimeout(() => {
				$("#errorMessage").fadeOut(1000);
			}, 1000);
		}
	}); 
});
/*
Populate Data for update transaction
*/
function populateEditForm(transaction) {
	$("#updateTransactionID").val(transaction.TRANSACTIONID);
	$('#transactionDate').val(transaction.DATE);
	$('#transactionType').val(transaction.TYPE);
	getCategoryByType(transaction.CATEGORY);
	$('#transactionDescription').val(transaction.DESCRIPTION);
	$('#transactionAmount').val(transaction.AMOUNT);
	// Clear the file input field
	$('#transactionReceipt').val('');
	// Display the current file if it exists
	if (transaction.FILEPATH) {
		let contentFileName = transaction.FILEPATH.split('/').pop();	   
		$('#currentFileContent').html('<a href=" ../../../Assignments/Mini_Project' + transaction.FILEPATH + '" target="_blank">' + contentFileName + '</a>');
	} else {
		$('#currentFileContent').html('No receipt uploaded');
	}
}
/*
Loads all transactions
*/
function loadTransactionTable(){
	$.ajax({
	  url: '../cfc/controllers/transactionController.cfc?method=getTransactionByUserID',
	  method: 'GET',
	  dataType: 'json',
	  success: function(response) {
		var result = response;
		if (result.success) {
			var transactions = result.transactions;
			Handlebars.registerHelper('incrementIndex', function(value) {
				return parseInt(value) + 1;
			  });
			$.ajax({
				url: '../templates/transactionList.hbs',
				type: 'GET',
				success: function(templateSource) {
					// Compile the Handlebars template
					var template = Handlebars.compile(templateSource);
					// Render the template with data
					$('#transaction-container').html(template(result));
					$('#transactionListTable').DataTable();
				},
				error: function(xhr, status, error) {
					$("#errorMessage").text("Template Fetch Error").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
				}
		});
	} else {
		$('#EmptyTransaction').removeClass('alert-success').addClass('No transaction Found').show();
	}
		
	  },    
	  error: function(xhr, status, error) {
		$("#errorMessage").text("Error Fetching transactions").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
	  }
	});

   
  }

$(document).on('click', '.editTransaction', function() {
	var transactionID = $(this).data('id');
	fetchTransactionById(transactionID);
});

$(document).on('click', '.deleteTransactionBtn', function() {
	var transactionID = $(this).data('id');
	deleteTransactionById(transactionID);
});

// Fetch transaction details by ID
function fetchTransactionById(transactionID) {
	$.ajax({
		url: '../cfc/controllers/transactionController.cfc?method=getTransactionById',
		method: 'POST',
		data: { transactionID: transactionID },
		dataType: 'json',
		success: function(response) {
			if (response.success) {
				populateEditForm(response.transactions[0]);
				$('#verticalycentered').modal('show');
			} else 
				$('#message').removeClass('alert-success').addClass('No transaction').show();
		},
		error: function(xhr, status, error) {
			$('#message	').removeClass('alert-success').addClass('No transaction').show();
		}
	}); 
}

$(document).on('click', '#updateTransactionBtn', function(event) {
	event.preventDefault(); // Prevent the default form submission
	var date = $('#transactionDate').val();
    var type = $('#transactionType').val();
    var category = $('#transactionCategory').val();
    var amount = $('#transactionAmount').val();
    var description = $('#transactionDescription').val();
    var receipt = $('#transactionReceipt').val();
	// Perform validation
    var isValid = validateForm(date, type, category, amount, description, receipt);

	if (isValid) {
		var formData = new FormData($('#updateTransactionForm')[0]); 
	
	if(!formData.get('type')){
		formData.append('type', $('#transactionType').val());
	}
	if(!formData.get('category')){
		formData.append('category', $('#transactionCategory').val());
	}
	if(!formData.get('type')){
		formData.append('type', $('#transactionType').val());
	}
	if(!formData.get('transactionID')){
		formData.append('transactionID', $('#updateTransactionID').val());
	}
	formData.append('date', $('#transactionDate').val());
	formData.append('description', $('#transactionDescription').val());
	formData.append('amount', parseInt($('#transactionAmount').val(),10));
	$.ajax({
		url: '../cfc/controllers/transactionController.cfc?method=updateTransaction',
		method: 'POST',
		data: formData,
		contentType: false, // Important: Do not set content type to allow multipart/form-data
		processData: false, // Important: Prevent jQuery from processing the data
		success: function(response) {
			var result = JSON.parse(response);
			if (result.SUCCESS) {
				loadTransactionTable();	
				$('#message1').removeClass('alert-dander').addClass('alert-success').text(result.MESSAGE).show();
				setTimeout(() => {
				$('#message1').removeClass('alert-dander').addClass('alert-success').text(result.MESSAGE).hide();
				$('#verticalycentered').modal('hide');
				}, 2000);
				
			} else {
				$("#errorMessage").text(result.message).show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
			}
		},
		error: function(xhr, status, error) {
			$("#errorMessage").text("Error adding transactuions").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
		}
	});
	}
});

$('#transactionType').change(function() { 
	getCategoryByType();
});

function getCategoryByType(value){

	var type = $('#transactionType').val();

	if (type === 'Income' || type === 'Expense') {
		// Enable category dropdown
		$('#transactionCategory').prop('disabled', false);

		// AJAX call to fetch categories based on type
		$.ajax({
			url: '../cfc/controllers/categoryController.cfc?method=getCategoriesByType',
			method: 'POST',
			data: { 
				type: type
			},
			success: function(response) {
				var result = JSON.parse(response);

				// Clear existing options
				$('#transactionCategory').empty();
				
				// Load the Handlebars template asynchronously
				$.get('../templates/categoryOptions.hbs', function(templateData) {
					// Compile Handlebars template
					var template = Handlebars.compile(templateData);
					// Render categories using the template
					var html = template(result);
					// Append options to select
					$('#transactionCategory').append(html);
					if(value){
						$('#transactionCategory').val(value);
					}
				   
				});
			},
			error: function(xhr, status, error) {
				$("#errorMessage").text("Error Fetching Categories").show();
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
	
}

function deleteTransactionById(transactionID) {
	if (!transactionID) {
		$('#message').removeClass('alert-success').addClass('alert-danger').text("Transaction ID is required.").show();
		return; // Exit the function if the ID is not available
	}
	// Show the custom confirmation modal
	$('#confirmDeleteModal').modal('show');
	// Handle the deletion confirmation
	$('#confirmDeleteBtn').off('click').on('click', function () {
		$('#confirmDeleteModal').modal('hide');
		$.ajax({
			url: '../cfc/controllers/transactionController.cfc?method=deleteTransaction',
			method: 'POST',
			data: { transactionID: transactionID },
			dataType: 'json',  // Expect JSON response from the server
			success: function(response) {
				if (response.success) {
					$('#message').removeClass('alert-danger').addClass('alert-success').text("Deleted transaction Successfully").show();
					setTimeout(() => {
						$('#message').removeClass('alert-danger').addClass('alert-success').text("Deleted transaction Successfully").hide();
						// Optionally refresh the transaction list or table
						loadTransactionTable();
					}, 2000);
				} else {
					$("#errorMessage").text("Could not delete the transaction.Please try again later.").show();
					setTimeout(() => {
						$("#errorMessage").fadeOut(1000);
					}, 1000);
				}
			},
			error: function(xhr, status, error) {
				$("#errorMessage").text("An error occurred while deleting the transaction.").show();
				setTimeout(() => {
					$("#errorMessage").fadeOut(1000);
				}, 1000);
			}
		});
	});
}

function showEditTransactionModal(currentDate, currency ,form) {
	// Load the Handlebars template asynchronously
	Handlebars.registerHelper('eq', function(a, b) {
		if (a === b) {
		  return true;
		}
		return false;
	});  
	$.get('../templates/transactionForm.hbs', function(templateData) {
	// Compile Handlebars template
	var template = Handlebars.compile(templateData);
	// Render the modal content using the template
	var html = template({
	currentDate: currentDate,
	currency: currency,
	form: form,
	});
	// Inject the rendered HTML into the placeholder and show the modal
	$('#modalPlaceholder').html(html);	  
	});
}
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