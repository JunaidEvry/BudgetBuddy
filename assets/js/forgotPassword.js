$(document).ready(function() {
    $('#resetPasswordForm').click(function(event) {
        event.preventDefault();

        var email = $('#yourEmail').val();
        // Email pattern regex
        var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!email) {
            $('.invalid-feedback').text('Please enter your email address!').show();
            return;
        } else if (!emailPattern.test(email)) {
            $('.invalid-feedback').text('Please enter a valid email address!').show();
            return;
        }

        $.ajax({
            url: '../cfc/controllers/userController.cfc?method=sendResetLink',
            type: 'POST',
            data: {
                email: email
            },
            success: function(response) {
                response = JSON.parse(response); // Parse the response to JSON
                if (response.success) {
                    $('.invalid-feedback').removeClass('alert-danger').addClass('alert-success').text(response.message).show();
                } else {
                    $('.invalid-feedback').addClass('alert-danger').text(response.message).show();
                }
            },
            error: function(response) {
                $('.invalid-feedback').addClass('alert-danger').text('Failed to send reset link. Please try again later.').show();
            }
        });
    });
});