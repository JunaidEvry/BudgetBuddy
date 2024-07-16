var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
  return new bootstrap.Tooltip(tooltipTriggerEl)
})
$(document).ready(function() {
  // Function to show validation messages
  function showError(element, message) {
	$(element).addClass('is-invalid').removeClass('is-valid');
	$(element).next('.invalid-feedback').text(message).show();
  }

  // Function to hide validation messages and show success
  function hideError(element) {
	$(element).removeClass('is-invalid').addClass('is-valid');
	$(element).next('.invalid-feedback').hide();
  }



  // Password pattern validation
  function isValidPassword(password) {
	var passwordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
	return passwordPattern.test(password);
  }

  // On form submit
  $('#resetPasswordForm').click(function(event) {
	// event.preventDefault();

	var isValid = false;

 

	// Get form values
	var password = $('#yourPassword').val();
	var confirmPassword = $('#confirmPassword').val();

	// Validate password
	if (!password) {
	  showError('#yourPassword', 'Please enter your new password!');
	
	} else if (!isValidPassword(password)) {
	  showError('#yourPassword', 'Password must contain: At least 8 characters, At least 1 uppercase letter, At least 1 lowercase letter, At least 1 number, At least 1 special character');
   
	} else {
	  hideError('#yourPassword');
	  // Validate confirm password
	  if (!confirmPassword) {
		showError('#confirmPassword', 'Please confirm your new password!');
	   
	  } else if (password !== confirmPassword) {
		showError('#confirmPassword', 'Passwords do not match!');
	 
	  } else {
		hideError('#confirmPassword');
		isValid = true;
	  }
  }
   
	if (isValid) {
	  var messageElement = $('#message');
	  // AJAX request
	  $.ajax({
		url: '../cfc/controllers/userController.cfc?method=resetPassword',
		type: 'POST',
		data: {
		  password: password,
		}, // Send formData as JSON object in the request body
		success: function(response) {
		  var result=JSON.parse(response);
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
		error: function(xhr, status, error) {
		  messageElement.removeClass('alert-success').addClass('alert-danger').text('Failed to reset password. Please try again later.').show();
	   
		}
	  });
	}
  });
});