component output="false" {

    /**
     * Retrieves all receipts for a specific user.
     * @param userID (required) - The ID of the user whose receipts are to be fetched.
     * @return An array of receipt records, including receiptID, date, category, amount, type, and filePath.
     */
    public array function getReceiptsByUserID(required numeric userID) {
        var dateFormat = session.usersettings.dateFormat; // Fetch date format from user settings
        var receipts = []; // Initialize an empty array to hold receipt data

        try {
            var query = new Query();
             // Set the datasource for the query
            query.setSQL("
                SELECT 
                    r.receiptID,
                    t.date,
                    c.name AS category,
                    t.amount,
                    t.type,
                    r.filePath
                FROM receipts r
                INNER JOIN transactions t ON r.transactionID = t.transactionID
                INNER JOIN categories c ON t.categoryID = c.categoryID
                WHERE t.userID = :userID
                ORDER BY t.date DESC
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer"); // Add userID parameter to the query

            var result = query.execute().getResult(); // Execute the query and get the result
            for (var i = 1; i <= result.recordCount; i++) {
                arrayAppend(receipts, {
                    receiptID: result.receiptID[i],
                    date: formatDate(result.date[i], dateFormat), // Format the date using the user's date format
                    category: result.category[i],
                    amount: result.amount[i],
                    type: result.type[i],
                    filePath: result.filePath[i]
                });
            }
        } catch (any e) {
            writeLog(file="Database", text="Error fetching receipts: " & e.message & "; Details: " & e.detail); // Log any errors that occur
        }

        return receipts; // Return the array of receipts
    }

    /**
     * Deletes a specific receipt from the database.
     * @param receiptID (required) - The ID of the receipt to be deleted.
     * @return A boolean indicating whether the receipt was successfully deleted.
     */
    public boolean function deleteReceipt(required numeric receiptID) {
        var success = false; // Initialize success flag to false

        try {
            var query = new Query();
             // Set the datasource for the query
            query.setSQL("DELETE FROM receipts WHERE receiptID = :receiptID"); // SQL query to delete the receipt
            query.addParam(name="receiptID", value=arguments.receiptID, cfsqltype="cf_sql_integer"); // Add receiptID parameter to the query

            query.execute(); // Execute the query
            success = true; // Set success flag to true if no errors occur
        } catch (any e) {
            writeLog(file="Database", text="Error deleting receipt: " & e.message & "; Details: " & e.detail); // Log any errors that occur
        }

        return success; // Return the success flag
    }

    /**
     * Formats a date according to the specified format.
     * @param inputDate (required) - The date to be formatted.
     * @param format (required) - The format string for the date.
     * @return The formatted date string.
     */
    public string function formatDate(date inputDate, string format) {
        return dateFormat(inputDate, format); // Formats the date using the provided format string
    }
}
