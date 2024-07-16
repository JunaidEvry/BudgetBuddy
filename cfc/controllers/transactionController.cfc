component output="false" {
    /**
     * Adds a new transaction to the database and handles the receipt upload if provided.
     * @param date (required) - The date of the transaction.
     * @param type (required) - The type of the transaction (income or expense).
     * @param category (required) - The category of the transaction.
     * @param amount (required) - The amount of the transaction.
     * @param description (required) - The description of the transaction.
     * @param receiptPath (optional) - The path of the receipt file to be uploaded.
     * @return A JSON structure containing success status and a message.
     */
    remote struct function addTransaction(
        required date date, 
        required string type, 
        required string category, 
        required numeric amount, 
        required string description, 
        string receiptPath
        ) returnFormat="json" {

        var result = { 
            "success" = false, 
            "message" = ""
        };

        try {
            // Get userID from session
            var userID = session.userID;

            // Get the category ID based on userID, type, and category name
            var transactionDAO = new cfc.models.TransactionDAO();
            var categoryId = transactionDAO.getCategoryID(userID, type, category);

            // Handle file upload
            var imagePath = "";
            var uploadDir = expandPath("../../uploads/receipts/");

            if (!categoryId) {
                throw(type="Application", message="Category not found.");
            }
            
            // Create the directory if it doesn't exist
            if (!directoryExists(uploadDir)) {
                directoryCreate(uploadDir);
            }

            // Check if receipt file was uploaded
            if (structKeyExists(arguments, "receipt") && arguments.receipt != "") {
                try {
                    // Perform file upload
                    var fileUploadResult = fileUpload(
                        destination="#uploadDir#", 
                        fileField="receipt", 
                        onConflict="makeunique"
                    );
                   
                    // Construct image path for database
                    imagePath = "/uploads/receipts/" & fileUploadResult.serverFile;
                } catch (any e) {
                    // Log the error but do not disrupt the transaction process
                    writeLog(file="Database", text="Error in uploading receipt: " & e.message & "; Details: " & e.detail);
                }
            }

            try {
                // Call DAO to insert transaction
                var insertTransactionResult = transactionDAO.insertTransaction(
                    userID, date, type, categoryId, amount, description
                );
            } catch (any e) {
                writeLog(file="Database", text="Error in transaction query: " & e.message & "; Details: " & e.detail);
            }
           
            if (insertTransactionResult.success) {
                result.message = "Transaction inserted successfully";

                // If receipt was uploaded, insert receipt path
                if (len(imagePath)) {
                    var insertReceiptResult = transactionDAO.insertReceipt(
                        insertTransactionResult.transactionID, imagePath
                    );

                    if (insertReceiptResult) {
                        result.success = true;
                    } else {
                        result.message = "Transaction inserted successfully, but failed to insert receipt.";
                    }
                } else {
                    // No receipt uploaded, continue with success
                    result.success = true;
                }
            } else {
                result.message = "Failed to insert transaction.";
            }
            
        } catch (any e) {
            writeLog(file="Database", text="Error adding transaction: " & e.message & "; Details: " & e.detail);
            result.message = "Error adding transaction: " & e.message;
        }

        return (result);
    }

    /**
     * Retrieves recent transactions for the current user.
     * @return A JSON structure containing success status, a list of transactions, and the user's currency.
     */
    remote struct function getRecentTransactions() returnFormat="json" {
        var result = { 
            "success" = false, 
            "message" = "", 
            "transactions" = [],
            "currency" = "" 
        };

        try {
            var userID = session.userID;
            result.currency = session.userSettings.currency;

            // Call the DAO to get recent transactions
            var transactionDAO = new cfc.models.transactionDAO();
            var transactions = transactionDAO.getRecentTransactions(userID);

            result.success = true;
            result.transactions = transactions;
        } catch (any e) {
            writeLog(file="Database", text="Error fetching recent transactions: " & e.message & "; Details: " & e.detail);
            result.message = "Error fetching recent transactions: " & e.message;
        }

        return result;
    }

    /**
     * Retrieves expense data for the current user.
     * @return A JSON structure containing success status and a list of expense data.
     */
    remote struct function getExpenseData() returnFormat="json" {
        var result = { success = false, data = [] };

        try {
            var userID = session.userID;
            var transactionDAO = new cfc.models.transactionDAO();
            result = transactionDAO.getExpenseData(userID);
        } catch (any e) {
            writeLog(file="Database", text="Error fetching expense data: " & e.message & "; Details: " & e.detail);
            result.message = "Error fetching expense data: " & e.message;
        }

        return result;
    }

    /**
     * Retrieves income data for the current user.
     * @return A JSON structure containing success status and a list of income data.
     */
    remote struct function getIncomeData() returnFormat="json" {
        var result = { success = false, data = [] };

        try {
            var userID = session.userID;
            var transactionDAO = new cfc.models.transactionDAO();
            result = transactionDAO.getIncomeData(userID);
        } catch (any e) {
            writeLog(file="Database", text="Error fetching income data: " & e.message & "; Details: " & e.detail);
            result.message = "Error fetching income data: " & e.message;
        }

        return result;
    }

    /**
     * Retrieves all transactions for the current user.
     * @return A JSON structure containing success status, a list of transactions, and the user's currency.
     */
    remote struct function getTransactionByUserID() returnFormat="json" {
        var result = { 
            "success" = false, 
            "message" = "", 
            "transactions" = [],
            "currency" = ""
        };

        try {
            var userID = session.userID;

            // Call the DAO to get transactions by userID
            var transactionDAO = new cfc.models.transactionDAO();
            var transactions = transactionDAO.getTransactionByUserID(userID);

            result.success = true;
            result.transactions = transactions;
            result.currency = session.usersettings.currency;
        } catch (any e) {
            writeLog(file="Database", text="Error fetching transactions: " & e.message & "; Details: " & e.detail);
            result.message = "Error fetching transactions: " & e.message;
        }

        return result;
    }

    /**
     * Updates an existing transaction based on the provided details.
     * @param transactionID (required) - The ID of the transaction to update.
     * @param date (required) - The new date of the transaction.
     * @param type (required) - The new type of the transaction (income or expense).
     * @param description (required) - The new description of the transaction.
     * @param amount (required) - The new amount of the transaction.
     * @param category (required) - The new category of the transaction.
     * @param receipt (optional) - The new receipt file to be uploaded.
     * @return A JSON structure containing the result of the update operation.
     */
    remote struct function updateTransaction(
        required numeric transactionID,
        required date date,
        required string type,
        required string description,
        required numeric amount,
        required string category,
        string receipt = ""
        ) returnFormat="json" {

        var result = {};
        var imagePath = "";
        var uploadDir = expandPath("../../uploads/receipts/");
        
        // Create the directory if it doesn't exist
        if (!directoryExists(uploadDir)) {
            directoryCreate(uploadDir);
        }

        // Check if receipt file was uploaded
        if (structKeyExists(arguments, "receipt") && arguments.receipt != "") {
            try {
                // Perform file upload
                var fileUploadResult = fileUpload(
                    destination="#uploadDir#", 
                    fileField="receipt", 
                    onConflict="makeunique"
                );
                
                // Construct image path for database
                imagePath = "/uploads/receipts/" & fileUploadResult.serverFile;
            } catch (any e) {
                writeLog(file="Database", text="Error updating transaction receipt: " & e.message & "; Details: " & e.detail);
            }
        }

        try {
            var transactionDAO = new cfc.models.transactionDAO();
            result = transactionDAO.updateTransaction(
                transactionID = transactionID,
                date = date,
                type = type,
                description = description,
                amount = amount,
                category = category,
                receiptPath = imagePath
            );

            if (!result.success) {
                result.message = "Error updating transaction: " & result.message;
            }
        } catch (any e) {
            result.success = false;
            writeLog(file="Database", text="Error updating transaction: " & e.message & "; Details: " & e.detail);
            result.message = "Error updating transaction: " & e.message;
        }

        // Return the result as JSON
        return result;
    }

    /**
     * Retrieves a transaction based on the provided transaction ID.
     * @param transactionID (required) - The ID of the transaction to retrieve.
     * @return A JSON structure containing success status, a list of transactions, and a message.
     */
    remote struct function getTransactionByID(requires String transactionID) returnFormat="json" {
        var result = { "success" = false, "message" = "", "transactions" = [] };

        try {
            // Call the DAO to get the transaction by ID
            var transactionDAO = new cfc.models.transactionDAO();
            var transactions = transactionDAO.getTransactionByID(arguments.transactionID);

            if (arrayLen(transactions) > 0) {
                result.success = true;
                result.transactions = transactions;
            } else {
                result.message = "No transaction found with the provided ID.";
            }
        } catch (any e) {
            writeLog(file="Database", text="Error fetching transaction by ID: " & e.message & "; Details: " & e.detail);
            result.message = "Error fetching transaction by ID: " & e.message;
        }

        return result;
    }

    /**
     * Deletes a transaction based on the provided transaction ID.
     * @param transactionID (required) - The ID of the transaction to delete.
     * @return A JSON structure containing success status and a message.
     */
    remote struct function deleteTransaction(
        required numeric transactionID
        ) returnFormat="json" {
        var result = {};

        try {
            // Create an instance of the transactionDAO
            var transactionDAO = new cfc.models.transactionDAO();

            // Call the DAO method to delete the transaction
            result = transactionDAO.deleteTransaction(transactionID = transactionID);

            // Check if the result was successful
            if (result.success) {
                result.message = "Transaction deleted successfully.";
            } else {
                result.message = "Error deleting transaction: " & result.message;
            }

        } catch (any e) {
            result.success = false;
            result.message = "Error deleting transaction: " & e.message;
            writeLog(file="Database", text="Error deleting transaction: " & e.message & "; Details: " & e.detail);
        }

        // Return the result as JSON
        return result;
    }

}