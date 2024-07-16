component output="false" {

    /**
     * Handles user sign-out by invalidating the session and logging the event.
     * @return A JSON object indicating success or failure of the sign-out operation.
     */
    remote struct function signOut() returnFormat="json" {
        var result = {
            "success": false,
            "message": ""
        };

        try {
            // Invalidate the session
            sessionInvalidate();
            result.success = true;
            result.message = "User signed out";

            // Optionally log the sign-out event
            writeLog(file="UserActions", text="User signed out: " & session.username);

        } catch (any e) {
            // Log any errors that occur during sign-out
            writeLog(file="UserActions", text="Failed sign out: because " & e.message & e.detail);
            result.message = "Unknown error occurred. Check UserActions log";
        }

        return result;
    }

    /**
     * Invalidates the session and clears the session scope.
     */
    private void function sessionInvalidate() {
        structClear(session); // Clear the session scope
        sessionInvalidate();  // Invalidate the session
    }

    /**
     * Registers a new user with the provided username, email, and password.
     * @param username (required) - The username for the new user.
     * @param email (required) - The email address for the new user.
     * @param password (required) - The password for the new user.
     * @return A JSON object indicating success or failure of the registration operation.
     */
    remote struct function registerUser(string username, string email, string password) returnFormat="json" {
        var result = {
            "success": false,
            "message": ""
        };

        // Welcome email body
        emailBody = "
            <h1>Welcome to BudgetBuddy!</h1>
            <p>Thank you for registering. We are excited to have you on board.</p>
            <p>Best Regards,<br>BudgetBuddy Team</p>
        ";

        // Create an instance of userDao
        var userDao = new cfc.models.userDao();

        // Check for duplicate email or username
        if (userDao.isEmailOrUsernameExists(arguments.email, arguments.username)) {
            result.message = "Email or Username already exists";

        } else {
            // Send a welcome email
            cfmail(
                to = "#arguments.email#",
                from = "budgetbuddy239@gmail.com",
                subject = "Welcome to BudgetBuddy",
                type = "html"
            ) {
                WriteOutput(emailBody);
            };

            // Register the user
            result.success = userDao.registerUser(username, email, password);
            
            if (result.success) {
                
                // Set session variables for the new user
                session.username = arguments.username;
                // session.userId = .userID;
                session.loggedIn = true;
                result.message = "Registration successful";
            } else {
                result.message = "Database Error Occurred";
            }
        }

        // Return JSON response
        return result;
    }

    /**
     * Logs in a user with the provided username and password.
     * @param username (required) - The username or email for the user.
     * @param password (required) - The password for the user.
     * @return A JSON object indicating success or failure of the login operation.
     */
    remote struct function loginUser(string username, string password) returnFormat="json" {
        var result = {
            "success": false,
            "message": ""
        };

        // Create an instance of userDao
        var userDao = new cfc.models.userDao();
        var user = userDao.getUserByUsernameOrEmail(arguments.username);

        if (user.recordCount == 0) {
            result.message = "Invalid username/email or password.";
        } else if (user.password != hash(arguments.password, "SHA-256")) {
            result.message = "Invalid username/email or password.";
        } else {
            // Fetch user settings
            var userSettingsDao = new cfc.models.userSettingsDao();
            var getUserSetting = userSettingsDao.getUserSettingsByUserID(user.userID);

            if (getUserSetting.SUCCESS) {
                session.userSettings = getUserSetting.settings;
            } else {
                session.userSettings = application.settings;
            }

            // Set session variables for the logged-in user
            session.loggedIn = true;
            session.username = user.username;
            session.userId = user.userID;
            result.success = true;
            result.message = "Login successful.";
        }

        return result;
    }

    /**
     * Resets the user's password.
     * @param password (required) - The new password for the user.
     * @return A JSON object indicating success or failure of the password reset operation.
     */
    remote struct function resetPassword(string password) returnFormat="json" {
        var result = {
            "success": false,
            "message": ""
        };

        // Create an instance of userDao
        var userDao = new cfc.models.userDao();
        var username = session.username; // Assuming the username is stored in session after reset link validation
        var updated = userDao.updatePassword(username, hash(password, "SHA-256"));
        userDao.deleteTokenByUsername(username);

        if (updated) {
            structDelete(session, "username");
            structDelete(session, "token");
            result.success = true;
            result.message = "Password reset successfully.";
        } else {
            result.message = "Failed to reset password. Please try again later.";
        }

        return result;
    }

    /**
     * Sends a password reset link to the specified email address.
     * @param email (required) - The email address to send the reset link to.
     * @return A JSON object indicating success or failure of the password reset link operation.
     */
    remote struct function sendResetLink(string email) returnFormat="json" {
        var result = {
            "success": false,
            "message": ""
        };

        // Create an instance of userDao
        var userDao = new cfc.models.userDao();
        var user = userDao.getUserByEmail(email);

        if (user.recordCount == 0) {
            result.message = "Email address not found.";
        } else {
            // Generate reset token
            var resetToken = createUUID();
            //Replace with dynamic link
            var resetLink = "http://localhost:8500/Assignments/Mini_Project/views/validateResetLink.cfm?token=" & resetToken;

            // Save reset token to the database
            userDao.saveResetToken(email, resetToken);

            // Send the reset email
            var emailBody = "
                <h1>Password Reset Request</h1>
                <p>To reset your password, please click the link below:</p>
                <p><a href='" & resetLink & "'>Reset Password</a></p>
                <p>If you did not request a password reset, please ignore this email.</p>
                <p>Best Regards,<br>BudgetBuddy Team</p>
            ";

            // cfsaveContent( emailBody = "
            // <h1>Password Reset Request</h1>
            // <p>To reset your password, please click the link below:</p>
            // <p><a href='" & resetLink & "'>Reset Password</a></p>
            // <p>If you did not request a password reset, please ignore this email.</p>
            // <p>Best Regards,<br>BudgetBuddy Team</p>
            // ";)

            try {
                cfmail(
                    to = email,
                    from = "budgetbuddy239@gmail.com",
                    subject = "BudgetBuddy Password Reset",
                    type = "html"
                ) {
                    WriteOutput(emailBody);
                };
                result.success = true;
                result.message = "Password reset link has been sent to your email address.";
            } catch (any e) {
                result.message = "Failed to send email. Please try again later.";
            }
        }

        return result;
    }

    /**
     * Retrieves the username of the currently logged-in user.
     * @return A JSON object containing the username of the current user.
     */
    remote struct function getUserName() returnFormat="json" {
        var result = {
            "success" = false,
            "userName" = ""
        };

        try {
            var userID = session.userID; // Assuming the userID is stored in the session
            var userDao = new cfc.models.UserDao();
            var userNameResult = userDao.getUserNameByID(userID);

            if (userNameResult.success) {
                result.success = true;
                result.userName = userNameResult.userName;
            } else {
                result.message = userNameResult.message;
            }

        } catch (any e) {
            result.message = "Error fetching username: " & e.message;
            writeLog(file="Application", text="Error fetching username: " & e.message & "; Details: " & e.detail);
        }

        return result;
    }
}
