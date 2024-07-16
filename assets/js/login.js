$(document).ready(function() {
	// Email pattern validation
	function isValidEmail(email) {
	  var emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
	  return emailPattern.test(email);
	}

	$('#loginsubmit').click(function(event) {
	  event.preventDefault();

	  var usernameOrEmail = $('#yourUsername').val();
	  var password = $('#yourPassword').val();

	  if (!usernameOrEmail || !password) {
		$('#loginMessage').addClass('alert-danger').text('Please enter both username/email and password.').show();
		return;
	  }

	  if (!isValidEmail(usernameOrEmail) && usernameOrEmail.indexOf('@') !== -1) {
		$('#loginMessage').addClass('alert-danger').text('Please enter a valid email address.').show();
		$('#yourUsername').focus();
		return;
	  }

	  $.ajax({
		url: '../cfc/controllers/userController.cfc?method=loginUser',
		type: 'POST',
		data: {
		  username: usernameOrEmail,
		  password: password
		},
		success: function(response) {
			var result=JSON.parse(response);
			console.log(result);
		  if (result.success) {
			$('#loginMessage').removeClass('alert-danger').addClass('alert-success').text('Login successful, redirecting...').show();
			setTimeout(function() {
			  window.location.href = "../index.cfm"; // Redirect to dashboard or home page
			}, 2000);
		  } else {
			$('#loginMessage').addClass('alert-danger').text(result.message).show();
		  }
		},
		error: function(response) {
		  $('#loginMessage').addClass('alert-danger').text('Login failed.').show();
		}
	  });
	});
  });