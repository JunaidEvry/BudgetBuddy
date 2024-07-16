<cfscript>
    param name="variables.token" default="";
    param name="url.token" default="";
    // Get the token from the URL parameter
    variables.token = url.token;

    // Check if the token is provided
    if (!len(token)) {
       location("pageNotFound.cfm",false);
    }


    // Instantiate the UserDAO component
    variables.userDao = new cfc.models.userDao(); // Adjust based on your application structure

    // Validate the token
    variables.user = userDao.getUserByToken(token);
    param name="user.username" default="";
    param name="user.resetToken" default="";
    if (!len(user.username) && !len(user.resetToken)) {
        // Handle invalid or expired token
        location("pageExpired.cfm",false);
    } else 
    {
        // Check if the token is expired
        if (now() > user.tokenExpiry) {
            location("pageExpired.cfm",false);
        }

        // Store the username and token in the session
        session.username = variables.user.username;
        session.token = variables.token;

        // Redirect to the reset password form
        
        location("resetPassword.cfm",false);

    }
</cfscript>
