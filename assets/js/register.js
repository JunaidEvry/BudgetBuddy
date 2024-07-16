var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
	return new bootstrap.Tooltip(tooltipTriggerEl)
})

$(document).ready(function() {
	// Function to show validation messages
	function showError(element, message) {
		$(element).addClass('is-invalid').removeClass('is-valid'); // Remove 'is-valid' class
		$(element).next('.invalid-feedback').text(message).show();
	}

	// Function to hide validation messages and show success
	function hideError(element) {
	 $(element).removeClass('is-invalid').addClass('is-valid'); // Add 'is-valid' class
		$(element).next('.invalid-feedback').hide();
	}

	// Function to reset validation styles
	function resetValidation(element) {
		$(element).removeClass('is-invalid').addClass('is-valid');
		$(element).next('.invalid-feedback').hide().text('');
	}

	// Email pattern validation
	function isValidEmail(email) {
		var emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
		return emailPattern.test(email);
	}

	// Password pattern validation
	function isValidPassword(password) {
		var passwordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
		return passwordPattern.test(password);
	}

	// On form submit
	$('#onsubmit').click( function(event) {
		event.preventDefault();

		var isValid = true;

		// Reset validation styles
		resetValidation('#yourEmail');
		resetValidation('#yourUsername');
		resetValidation('#yourPassword');
		resetValidation('#confirmPassword');
		resetValidation('#acceptTerms');

		// Get form values
		var email = $('#yourEmail').val().trim();
		var username = $('#yourUsername').val().trim();
		var password = $('#yourPassword').val();
		var confirmPassword = $('#confirmPassword').val();

		// Validate email
		if (!email) {
			showError('#yourEmail', 'Please enter a valid Email address!');
			isValid = false;
		} else if (!isValidEmail(email)) {
			showError('#yourEmail', 'Invalid Email address!');
			isValid = false;
		}else{
			hideError('#yourEmail');
		}
		// Validate username
		if (!username) {
			showError('#yourUsername', 'Please choose a username.');
			isValid = false;
		}else{
			hideError('#yourUsername');
		}

		// Validate password
		if (!password) {
			showError('#yourPassword', 'Please enter your password!');
			isValid = false;
		} else if (!isValidPassword(password)) {
			showError('#yourPassword', 'Password must contain: At least 8 characters, At least 1 uppercase letter, At least 1 lowercase letter, At least 1 number, At least 1 special character');
			isValid = false;
		}else{
			hideError('#yourPassword');
		}

		// Validate confirm password
		if (!confirmPassword) {
			showError('#confirmPassword', 'Please confirm your password!');
			isValid = false;
		} else if (password != confirmPassword) {
			showError('#confirmPassword', 'Passwords do not match!');
			isValid = false;
		}else{
			hideError('#confirmPassword');
		}

		// Validate terms and conditions
		if (!$('#acceptTerms').is(':checked')) {
			showError('#acceptTerms', 'You must agree before submitting.');
			isValid = false;
		}else{
			hideError('#acceptTerms');
		}

		// If all validations pass, submit the form
		if (isValid) {
			$.ajax({
				url: '../cfc/controllers/userController.cfc?method=registerUser',
				type: 'POST',
				data: {
					email: email,
					username: username,
					password: password
				},
				success: function(response) {
					
					var result=JSON.parse(response);
				
					var messageElement = $('#registrationMessage');

					if (result.success) {

						messageElement.removeClass('alert-danger').addClass('alert-success').text(result.message).show();
						// Optionally, redirect the user to the login page after a delay
						setTimeout(function() {
							
							window.location.href = '../index.cfm';
						}, 2000);
					} else {
						messageElement.removeClass('alert-success').addClass('alert-danger').text(result.message).show();
					}
				},
				error: function() {
					$('#registrationMessage').removeClass('alert-success').addClass('alert-danger').text('An error occurred during registration. Please try again.').show();
				}
			}); 
		}
	});
});