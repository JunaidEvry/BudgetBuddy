component output="false" {

    /**
     * Checks if an email or username already exists in the Users table.
     * @param string email - The email to check.
     * @param string username - The username to check.
     * @return boolean - True if either email or username exists, otherwise false.
     */
    public boolean function isEmailOrUsernameExists(string email, string username) {
        var exists = false;
        var qry = new query();
        qry.setDatasource("FinanceManager");
        qry.setSQL("
            SELECT COUNT(*) AS cnt
            FROM Users
            WHERE Email = :email
            OR Username = :username
        ");
        qry.addParam(name="email", value=email, cfsqltype="cf_sql_varchar");
        qry.addParam(name="username", value=username, cfsqltype="cf_sql_varchar");
        var result = qry.execute().getResult();

        if (result.cnt > 0) {
            exists = true;
        }

        return exists;
    }

    /**
     * Registers a new user in the Users table.
     * @param string username - The username of the new user.
     * @param string email - The email of the new user.
     * @param string password - The password of the new user (will be hashed).
     * @return boolean - True if registration was successful, otherwise false.
     */
    public boolean function registerUser(string username, string email, string password) {
        try {
            var qry = new query();
            qry.setDatasource("FinanceManager");
            qry.setSQL("
                INSERT INTO Users (Username, Email, Password, CreatedAt, UpdatedAt)
                VALUES (:username, :email, :password, GETDATE(), GETDATE())
            ");
            qry.addParam(name="username", value=arguments.username, cfsqltype="cf_sql_varchar");
            qry.addParam(name="email", value=arguments.email, cfsqltype="cf_sql_varchar");
            qry.addParam(name="password", value=hash(arguments.password, "SHA-256"), cfsqltype="cf_sql_varchar");
            qry.execute();

        } catch (any e) {
            // Log the error
            writeLog(file="Database", text="Error registering user: " & e.message & "; Details: " & e.detail);
            return false;
        }
        return true;
    }

    /**
     * Retrieves user details by either username or email.
     * @param string usernameOrEmail - The username or email to search for.
     * @return query - The query result containing user details.
     */
    public query function getUserByUsernameOrEmail(string usernameOrEmail) {
        var qry = new query();
        qry.setDatasource("FinanceManager");
        qry.setSQL("
            SELECT *
            FROM Users
            WHERE Username = :usernameOrEmail
            OR Email = :usernameOrEmail
        ");
        qry.addParam(name="usernameOrEmail", value=usernameOrEmail, cfsqltype="cf_sql_varchar");
        return qry.execute().getResult();
    }

    /**
     * Retrieves user details by email.
     * @param string email - The email to search for.
     * @return query - The query result containing user details.
     */
    public query function getUserByEmail(string email) {
        var qry = new query();
        qry.setDatasource("FinanceManager");
        qry.setSQL("
            SELECT *
            FROM Users
            WHERE Email = :email
        ");
        qry.addParam(name="email", value=email, cfsqltype="cf_sql_varchar");
        return qry.execute().getResult();
    }

    /**
     * Saves a password reset token for a user.
     * @param string email - The email of the user.
     * @param string resetToken - The reset token to be saved.
     */
    public void function saveResetToken(string email, string resetToken) {
        var qry = new query();
        qry.setDatasource("FinanceManager");
        qry.setSQL("
            UPDATE Users
            SET ResetToken = :resetToken, TokenExpiry = DATEADD(hh, 1, GETDATE())
            WHERE Email = :email
        ");
        qry.addParam(name="email", value=email, cfsqltype="cf_sql_varchar");
        qry.addParam(name="resetToken", value=resetToken, cfsqltype="cf_sql_varchar");
        qry.execute();
    }

    /**
     * Updates the password for a user.
     * @param string username - The username of the user.
     * @param string hashedPassword - The new hashed password.
     * @return boolean - True if the update was successful, otherwise false.
     */
    public boolean function updatePassword(string username, string hashedPassword) {
        var success = false;
        var qry = new query();
        qry.setDatasource("FinanceManager");
        qry.setSQL("
            UPDATE Users
            SET Password = :hashedPassword,
                UpdatedAt = GETDATE()  -- Assuming UpdatedAt field exists
            WHERE Username = :username
        ");
        qry.addParam(name="hashedPassword", value=hashedPassword, cfsqltype="cf_sql_varchar");
        qry.addParam(name="username", value=username, cfsqltype="cf_sql_varchar");

        try {
            qry.execute();
            success = true;
        } catch (any e) {
            // Handle any database errors
            writeLog(file="Database", text="Error updating password: " & e.message);
        }

        return success;
    }

    /**
     * Retrieves user details by the reset token.
     * @param string token - The reset token.
     * @return struct - A structure containing username and token expiry, or an empty structure if the token is invalid.
     */
    public struct function getUserByToken(string token) {
        var result = {};
        var qry = new query();
        qry.setDatasource("FinanceManager");
        qry.setSQL("
            SELECT Username, TokenExpiry
            FROM Users
            WHERE ResetToken = :token
            AND TokenExpiry > GETDATE()
        ");
        qry.addParam(name="token", value=arguments.token, cfsqltype="cf_sql_varchar");
        var queryResult = qry.execute().getResult();
        param name="queryResult.recordCount" default=0;
        if (queryResult.recordCount > 0) {
            result.username = queryResult.Username;
            result.tokenExpiry = queryResult.TokenExpiry;
        } else {
            result = {};
        }

        return result;
    }

    /**
     * Sets the reset token to NULL for a specific username.
     * @param string username - The username of the user whose token will be set to NULL.
     * @return boolean - True if the update was successful, otherwise false.
     */
    public boolean function deleteTokenByUsername(username) {
        var success = false;

        try {
            // Build the SQL statement to set token to NULL
            var sql = "UPDATE Users SET ResetToken = NULL WHERE Username = :username";

            // Create a query object
            var qry = new Query();
            qry.setDatasource("FinanceManager"); // Replace with your actual datasource name

            // Set the SQL statement and parameters
            qry.setSQL(sql);
            qry.addParam(name="username", value=arguments.username, cfsqltype="cf_sql_varchar");

            // Execute the query
            qryResult = qry.execute();

            // Check if the query was successful
            if (qryResult.recordCount > 0) {
                success = true;
            }

        } catch (any e) {
            // Log the error if an exception occurs
            writeLog(file="Database", text="Error setting token to NULL for username " & arguments.username & ": " & e.message);
        }

        return success;
    }

    /**
     * Retrieves the username for a given user ID.
     * @param numeric userID - The ID of the user.
     * @return struct - A structure containing success status, username, or an error message.
     */
    public struct function getUserNameByID(required numeric userID) {
        var result = { success = false, userName = "", message = "" };

        try {
            var query = new Query();

            query.setSQL("
                SELECT Username
                FROM Users
                WHERE UserID = :userID
            ");
            query.addParam(name="userID", value=userID, cfsqltype="cf_sql_integer");

            var queryResult = query.execute().getResult();

            if (queryResult.recordCount > 0) {
                result.success = true;
                result.userName = queryResult.Username;
            } else {
                result.message = "User not found.";
            }

        } catch (any e) {
            result.message = "Error fetching username: " & e.message;
            writeLog(file="Application", text="Error fetching username: " & e.message & "; Details: " & e.detail);
        }

        return result;
    }

}
