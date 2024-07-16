component output="false" {

    /**
     * Retrieves the category ID for a given user, type, and category name.
     * @param string userID - The ID of the user.
     * @param string type - The type of the category (e.g., expense, income).
     * @param string category - The name of the category.
     * @return numeric - The ID of the category.
     */
    public numeric function getCategoryID(
        required string userID, 
        required string type, 
        required string category) {

        var categoryId = 0;  // Initialize categoryId with a default value of 0.
        try {
            var query = new Query();
            query.setSQL("
                SELECT categoryId 
                FROM categories 
                WHERE userID = :userID AND type = :type AND name = :category
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");
            query.addParam(name="type", value=arguments.type, cfsqltype="cf_sql_varchar");
            query.addParam(name="category", value=arguments.category, cfsqltype="cf_sql_varchar");
            var result = query.execute().getResult();
            if (result.recordCount > 0) {
                categoryId = result.categoryId[1];  // Retrieve the category ID from the query result.
            }
        } catch (any e) {
            // Log any error that occurs during the query execution.
            writeLog(file="Database", text="Error retrieving category ID: " & e.message & "; Details: " & e.detail);
        }

        return categoryId;  // Return the retrieved category ID.
    }

    /**
     * Inserts a new transaction into the transactions table.
     * @param numeric userId - The ID of the user.
     * @param date date - The date of the transaction.
     * @param string type - The type of the transaction (e.g., expense, income).
     * @param numeric categoryId - The ID of the category.
     * @param numeric amount - The amount of the transaction.
     * @param string description - A description of the transaction.
     * @return struct - A structure containing success status and the transaction ID.
     */
    public struct function insertTransaction(
        required numeric userId, 
        required date date, 
        required string type, 
        required numeric categoryId, 
        required numeric amount, 
        required string description) {

        var result = {
            "success": false,
            "transactionId": 0  // Initialize transactionId with a default value of 0.
        };

        // Get TimeZone based Date from the utils
        var getDateTime = new cfc.utils.getDateTime();
        var formattedDate = getDateTime.getTimeZoneDate();

        try {
            var query = new Query();
            query.setSQL("
                INSERT INTO transactions (
                    userID,
                    Date, 
                    Type, 
                    CategoryId, 
                    Amount, 
                    Description,
                    CreatedAt
                ) VALUES (
                    :userId,
                    :date, 
                    :type, 
                    :categoryId, 
                    :amount, 
                    :description,
                    :formattedDate
                );
            ");
            query.addParam(name="date", value=arguments.date, cfsqltype="cf_sql_date");
            query.addParam(name="type", value=arguments.type, cfsqltype="cf_sql_varchar");
            query.addParam(name="categoryId", value=arguments.categoryId, cfsqltype="cf_sql_integer");
            query.addParam(name="amount", value=arguments.amount, cfsqltype="cf_sql_numeric");
            query.addParam(name="description", value=arguments.description, cfsqltype="cf_sql_varchar");
            query.addParam(name="userId", value=arguments.userId, cfsqltype="cf_sql_integer");
            query.addParam(name="formattedDate", value=formattedDate, cfsqltype="cf_sql_varchar");
            var insertResult = query.execute().getPrefix();
            // Check if the query executed successfully and retrieve the generated transaction ID.
            if (insertResult.recordCount) {
                result.success = true;
                result.transactionId = insertResult.generatedkey;
            } else {
                throw(type="Application", message="Failed to insert transaction.");
            }
        } catch (any e) {
            // Log any error that occurs during the query execution.
            writeLog(file="Database", text="Error adding transaction: " & e.message & "; Details: " & e.detail);
        }

        return result;  // Return the result structure containing success status and transaction ID.
    }

    /**
     * Inserts a receipt record into the receipts table.
     * @param numeric transactionId - The ID of the associated transaction.
     * @param string receiptPath - The file path of the receipt.
     * @return boolean - True if the insertion was successful, otherwise false.
     */
    public boolean function insertReceipt(
        required numeric transactionId, 
        required string receiptPath) {

        var success = false;

        // Get TimeZone based Date from the utils
        var getDateTime = new cfc.utils.getDateTime();
        var formattedDate = getDateTime.getTimeZoneDate();

        try {
            var query = new Query();
            query.setSQL("
                INSERT INTO receipts (
                    transactionId, 
                    FilePath,
                    UploadDate
                ) VALUES (
                    :transactionId, 
                    :receiptPath,
                    :formattedDate
                )
            ");
            query.addParam(name="transactionId", value=arguments.transactionId, cfsqltype="cf_sql_integer");
            query.addParam(name="receiptPath", value=arguments.receiptPath, cfsqltype="cf_sql_varchar");
            query.addParam(name="formattedDate", value=formattedDate, cfsqltype="cf_sql_varchar");
            query.execute();
            success = true;
        } catch (any e) {
            // Log any error that occurs during the query execution.
            writeLog(file="Database", text="Error adding receipt: " & e.message & "; Details: " & e.detail);
        }

        return success;  // Return true if the insertion was successful, otherwise false.
    }


    /**
     * Retrieves the most recent transactions for a given user.
     * @param numeric userId - The ID of the user.
     * @return array - An array of structs containing recent transactions.
     */
    public array function getRecentTransactions(
        required numeric userId) {

        var transactions = [];  // Initialize an empty array to hold the transactions.
        var dateFormat = session.usersettings.dateFormat;  // Get the user's date format setting.

        try {
            var query = new Query();
            query.setSQL("
                SELECT TOP 10
                    transactionId,
                    t.userId,
                    Date AS date,
                    t.categoryId as categoryID,
                    Name as categoryName,
                    Amount AS amount,
                    Description AS description
                FROM transactions t
                INNER JOIN categories c 
                ON c.categoryId = t.categoryId 
                WHERE t.userId = :userId
                ORDER BY Date DESC
            ");
            query.addParam(name="userId", value=arguments.userId, cfsqltype="cf_sql_integer");
            var result = query.execute().getResult();

            // Convert query result to an array of structs
            for (var row in result) { 
                var data = {
                    "transactionId": row.transactionId,
                    "userId": row.userId,
                    "date": dateFormat(row.date, dateFormat),  // Format the date using the user's date format setting.
                    "category": row.categoryName,
                    "amount": row.amount,
                    "description": row.description
                }
                arrayAppend(transactions, data);  // Append the transaction data to the array.
            }
        } catch (any e) {
            // Log any error that occurs during the query execution.
            writeLog(file="Database", text="Error retrieving recent transactions: " & e.message & "; Details: " & e.detail);
        }

        return transactions;  // Return the array of recent transactions.
    }

    /**
     * Fetches the expense data grouped by category for a given user.
     * @param numeric userId - The ID of the user.
     * @return struct - A structure containing success status and an array of expense data.
     */
    public struct function getExpenseData(required numeric userId) {
        var result = { success = false, data = [] };  // Initialize the result structure.

        try {
            var query = new Query();
            query.setSQL("
                SELECT c.Name, SUM(t.Amount) AS TotalAmount
                FROM transactions t
                INNER JOIN categories c ON t.CategoryId = c.CategoryId
                WHERE t.userId = :userId AND t.Type = 'Expense'
                GROUP BY c.Name
            ");
            query.addParam(name="userId", value=arguments.userId, cfsqltype="cf_sql_integer");

            var queryResult = query.execute().getResult();
            result.data = queryResult;  // Assign the query result to the data field.
            result.success = true;  // Set success to true since the query executed without errors.
        } catch (any e) {
            // Log any error that occurs during the query execution.
            writeLog(file="Database", text="Error fetching expense data: " & e.message & "; Details: " & e.detail);
        }

        return result;  // Return the result structure containing success status and expense data.
    }

    /**
     * Fetches the income data grouped by category for a given user.
     * @param numeric userId - The ID of the user.
     * @return struct - A structure containing success status and an array of income data.
     */
    public struct function getIncomeData(required numeric userId) {
        var result = { success = false, data = [] };  // Initialize the result structure.

        try {
            var query = new Query();
            query.setSQL("
                SELECT c.Name, SUM(t.Amount) AS TotalAmount
                FROM transactions t
                INNER JOIN categories c ON t.CategoryId = c.CategoryId
                WHERE t.userId = :userId AND t.Type = 'Income'
                GROUP BY c.Name
            ");
            query.addParam(name="userId", value=arguments.userId, cfsqltype="cf_sql_integer");

            var queryResult = query.execute().getResult();
            result.data = queryResult;  // Assign the query result to the data field.
            result.success = true;  // Set success to true since the query executed without errors.
        } catch (any e) {
            // Log any error that occurs during the query execution.
            writeLog(file="Database", text="Error fetching income data: " & e.message & "; Details: " & e.detail);
        }

        return result;  // Return the result structure containing success status and income data.
    }


    /**
     * Retrieves weekly expenses for a given user between the start and end dates of the week.
     * @param numeric userID - The ID of the user.
     * @param date weekStart - The start date of the week.
     * @return array - An array of expense totals for each day of the week.
     */
    public array function getWeeklyExpenses(required numeric userID, required date weekStart) {
        var weekEnd = dateAdd("d", -7, arguments.weekStart);  // Calculate the end date of the week.
        var result = [];  // Initialize an empty array to hold the weekly expenses.

        try {
            var query = new Query();
            query.setSQL("
                WITH WeekDays AS (
                    SELECT 1 AS DayOfWeek, 'Sun' AS DayName UNION ALL
                    SELECT 2, 'Mon' UNION ALL
                    SELECT 3, 'Tue' UNION ALL
                    SELECT 4, 'Wed' UNION ALL
                    SELECT 5, 'Thu' UNION ALL
                    SELECT 6, 'Fri' UNION ALL
                    SELECT 7, 'Sat'
                )

                SELECT 
                    wd.DayOfWeek,
                    wd.DayName,
                    ISNULL(SUM(t.Amount), 0) AS TotalAmount
                FROM 
                    WeekDays wd
                LEFT JOIN 
                    transactions t
                ON 
                    wd.DayOfWeek = DATEPART(dw, t.Date)
                    AND t.userID = :userID
                    AND t.Date BETWEEN :weekEnd AND :weekStart
                    AND t.Type = 'Expense'
                GROUP BY 
                    wd.DayOfWeek, wd.DayName
                ORDER BY 
                    wd.DayOfWeek;
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");
            query.addParam(name="weekStart", value=arguments.weekStart, cfsqltype="cf_sql_date");
            query.addParam(name="weekEnd", value=weekEnd, cfsqltype="cf_sql_date");

            var queryResult = query.execute().getResult();

            // Populate the result array with total expenses for each day of the week.
            for (var row in queryResult) {
                arrayAppend(result, row.TotalAmount);
            }
        } catch (any e) {
            // Log any errors encountered during the query execution.
            writeLog(file="Database", text="Error fetching weekly expenses: " & e.message & "; Details: " & e.detail);
        }

        return result;  // Return the array of weekly expenses.
    }

    /**
     * Retrieves weekly income for a given user between the start and end dates of the week.
     * @param numeric userID - The ID of the user.
     * @param date weekStart - The start date of the week.
     * @return array - An array of income totals for each day of the week.
     */
    public array function getWeeklyIncome(required numeric userID, required date weekStart) {
        var weekEnd = dateAdd("d", -7, arguments.weekStart);  // Calculate the end date of the week.
        var result = [];  // Initialize an empty array to hold the weekly income.

        try {
            var query = new Query();
            query.setSQL("
                WITH WeekDays AS (
                    SELECT 1 AS DayOfWeek, 'Sun' AS DayName UNION ALL
                    SELECT 2, 'Mon' UNION ALL
                    SELECT 3, 'Tue' UNION ALL
                    SELECT 4, 'Wed' UNION ALL
                    SELECT 5, 'Thu' UNION ALL
                    SELECT 6, 'Fri' UNION ALL
                    SELECT 7, 'Sat'
                )

                SELECT 
                    wd.DayOfWeek,
                    wd.DayName,
                    ISNULL(SUM(t.Amount), 0) AS TotalAmount
                FROM 
                    WeekDays wd
                LEFT JOIN 
                    transactions t
                ON 
                    wd.DayOfWeek = DATEPART(dw, t.Date)
                    AND t.userID = :userID
                    AND t.Date BETWEEN :weekEnd AND :weekStart
                    AND t.Type = 'Income'
                GROUP BY 
                    wd.DayOfWeek, wd.DayName
                ORDER BY 
                    wd.DayOfWeek;
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");
            query.addParam(name="weekStart", value=arguments.weekStart, cfsqltype="cf_sql_date");
            query.addParam(name="weekEnd", value=weekEnd, cfsqltype="cf_sql_date");

            var queryResult = query.execute().getResult();
            
            // Populate the result array with total income for each day of the week.
            for (var row in queryResult) {
                arrayAppend(result, row.TotalAmount);
            }
        } catch (any e) {
            // Log any errors encountered during the query execution.
            writeLog(file="Database", text="Error fetching weekly income: " & e.message & "; Details: " & e.detail);
        }

        return result;  // Return the array of weekly income.
    }

    /**
     * Retrieves the total income for each month of the current year for a given user.
     * @param numeric userID - The ID of the user.
     * @return array - An array of monthly income totals for the current year.
     */
    public array function getYearlyIncomeData(required numeric userID) {
        var query = new Query();
        var result = arrayNew(1);  // Initialize a new array for storing monthly income data.
        arrayResize(result, 12);  // Resize the array to have 12 elements (one for each month of the year).
        for (var i = 1; i <= 12; i++) {
            result[i] = 0;  // Initialize each month with 0 income.
        }

        try {
            query.setSQL("
                SELECT 
                    MONTH(Date) AS Month,
                    SUM(Amount) AS TotalAmount
                FROM 
                    transactions
                WHERE 
                    userID = :userID
                    AND Type = 'Income'
                    AND YEAR(Date) = YEAR(GETDATE())
                GROUP BY 
                    MONTH(Date)
                ORDER BY 
                    MONTH(Date)
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");

            var queryResult = query.execute().getResult();

            // Populate the result array with total income for each month.
            for (var row in queryResult) {
                result[row.Month] = row.TotalAmount;
            }
        } catch (any e) {
            // Log any errors encountered during the query execution.
            writeLog(file="Database", text="Error fetching yearly income: " & e.message & "; Details: " & e.detail);
        }

        return result;  // Return the array of yearly income data.
    }

    /**
     * Retrieves the total expenses for each month of the current year for a given user.
     * @param numeric userID - The ID of the user.
     * @return array - An array of monthly expense totals for the current year.
     */
    public array function getYearlyExpenseData(required numeric userID) {
        var query = new Query();
        var result = arrayNew(1);  // Initialize a new array for storing monthly expense data.
        arrayResize(result, 12);  // Resize the array to have 12 elements (one for each month of the year).
        for (var i = 1; i <= 12; i++) {
            result[i] = 0;  // Initialize each month with 0 expense.
        }

        try {
            query.setSQL("
                SELECT 
                    MONTH(Date) AS Month,
                    SUM(Amount) AS TotalAmount
                FROM 
                    transactions
                WHERE 
                    userID = :userID
                    AND Type = 'Expense'
                    AND YEAR(Date) = YEAR(GETDATE())
                GROUP BY 
                    MONTH(Date)
                ORDER BY 
                    MONTH(Date)
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");

            var queryResult = query.execute().getResult();

            // Populate the result array with total expenses for each month.
            for (var row in queryResult) {
                result[row.Month] = row.TotalAmount;
            }
        } catch (any e) {
            // Log any errors encountered during the query execution.
            writeLog(file="Database", text="Error fetching yearly expenses: " & e.message & "; Details: " & e.detail);
        }

        return result;  // Return the array of yearly expense data.
    }
    
    /**
     * Retrieves monthly data for a given user based on the type of transaction (Income or Expense).
     * @param numeric userID - The ID of the user.
     * @param numeric month - The month for which the data is to be fetched.
     * @param numeric year - The year for which the data is to be fetched.
     * @param string type - The type of transactions to retrieve ('Income' or 'Expense').
     * @return struct - A struct with category names as keys and total amounts as values.
     */
    public struct function getMonthlyData(required numeric userID, required numeric month, required numeric year, required string type) {
        var query = new Query();
        var result = {};  // Initialize an empty struct to hold the monthly data.

        try {
            query.setSQL("
                SELECT 
                    c.Name AS Category,
                    SUM(t.Amount) AS TotalAmount
                FROM 
                    transactions t
                INNER JOIN
                    categories c ON t.categoryID = c.categoryID
                WHERE 
                    t.userID = :userID
                    AND t.Type = :type
                    AND MONTH(t.Date) = :month
                    AND YEAR(t.Date) = :year
                GROUP BY 
                    c.Name
                ORDER BY 
                    c.Name
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");
            query.addParam(name="type", value=arguments.type, cfsqltype="cf_sql_varchar");
            query.addParam(name="month", value=arguments.month, cfsqltype="cf_sql_integer");
            query.addParam(name="year", value=arguments.year, cfsqltype="cf_sql_integer");

            var queryResult = query.execute().getResult();

            // Populate the result struct with category names and their corresponding total amounts.
            for (var row in queryResult) {
                result[row.Category] = row.TotalAmount;
            }
        } catch (any e) {
            // Log any errors encountered during the query execution.
            writeLog(file="Database", text="Error fetching monthly data: " & e.message & "; Details: " & e.detail);
        }

        return result;  // Return the struct containing the monthly data.
    }

    /**
     * Retrieves all transactions for a given user, including category, description, date, and amount.
     * @param numeric userID - The ID of the user.
     * @return array - An array of structs representing the transactions.
     */
    public array function getTransactionByUserID(required numeric userID) {
        var dateFormat = session.usersettings.dateFormat;  // Get the date format from user settings.
        var transactions = [];  // Initialize an empty array to hold the transactions.

        try {
            var query = new Query();
            query.setSQL("
                SELECT 
                    t.transactionID,
                    c.name AS category,
                    t.description,
                    t.date,
                    t.amount
                FROM transactions t
                INNER JOIN categories c ON t.categoryID = c.categoryID
                WHERE t.userID = :userID
                ORDER BY t.date DESC
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");

            var result = query.execute().getResult();

            // Convert query result to array of structs with transaction details.
            for (var row in result) {
                var data = {
                    "transactionID": row.transactionID,
                    "category": row.category,
                    "description": row.description,
                    "date": dateFormat(row.date, dateFormat),  // Format the date based on user settings.
                    "amount": row.amount
                };
                arrayAppend(transactions, data);
            }
        } catch (any e) {
            // Log any errors encountered during the query execution.
            writeLog(file="Database", text="Error retrieving transactions by userID: " & e.message & "; Details: " & e.detail);
        }

        return transactions;  // Return the array of transactions.
    }

    /**
     * Updates an existing transaction with new details and optionally updates the associated receipt.
     * @param numeric transactionID - The ID of the transaction to be updated.
     * @param date date - The new date for the transaction.
     * @param string type - The new type of the transaction (Income or Expense).
     * @param string description - The new description of the transaction.
     * @param numeric amount - The new amount for the transaction.
     * @param string category - The new category for the transaction.
     * @param string receiptPath - Optional path for the receipt file.
     * @return struct - A struct indicating the success or failure of the update operation.
     */
    public struct function updateTransaction(
        required numeric transactionID,
        required date date,
        required string type,
        required string description,
        required numeric amount,
        required string category,
        string receiptPath = ""
        ) { 
        var result = {};

        try {
            var getDateTime = new cfc.utils.getDateTime();
            var formattedDate = getDateTime.getTimeZoneDate();  // Get the current date and time for the update.

            // Update the transaction details.
            var updateQuery = new Query();
            updateQuery.setSQL("
                UPDATE transactions
                SET
                    date = :date,
                    type = :type,
                    description = :description,
                    amount = :amount,
                    updatedAt = :formattedDate,
                    categoryID = (SELECT TOP 1 categoryID FROM categories WHERE name = :category AND type = :type ORDER BY categoryID)
                WHERE transactionID = :transactionID
            ");
            updateQuery.addParam(name="date", value=arguments.date, cfsqltype="cf_sql_date");
            updateQuery.addParam(name="type", value=arguments.type, cfsqltype="cf_sql_varchar");
            updateQuery.addParam(name="description", value=arguments.description, cfsqltype="cf_sql_varchar");
            updateQuery.addParam(name="amount", value=arguments.amount, cfsqltype="cf_sql_numeric");
            updateQuery.addParam(name="category", value=arguments.category, cfsqltype="cf_sql_varchar");
            updateQuery.addParam(name="transactionID", value=arguments.transactionID, cfsqltype="cf_sql_integer");
            updateQuery.addParam(name="formattedDate", value=formattedDate, cfsqltype="cf_sql_varchar");
            var updateResult = updateQuery.execute().getPrefix();

            if (updateResult.recordCount>0) {
                result.success = true;
                result.message = "Transaction updated successfully.";
            } else {
                result.success = false;
                result.message = "Transaction update failed.";
            }

            // Update or insert receipt information if receiptPath is provided.
            if (receiptPath != "") {
                var updateReceiptQuery = new Query();
                updateReceiptQuery.setDatasource("FinanceManager");

                try {
                    var formattedDate = getTimeZoneDate();  // Get the current date and time for the receipt update.

                    // Check if the transactionID exists in the receipts table.
                    updateReceiptQuery.setSQL("
                        SELECT COUNT(*) AS Count
                        FROM receipts
                        WHERE transactionID = :transactionID
                    ");
                    updateReceiptQuery.addParam(name="transactionID", value=arguments.transactionID, cfsqltype="cf_sql_integer");
                    var checkResult = updateReceiptQuery.execute().getResult();

                    if (checkResult.Count > 0) {
                        // If transactionID exists, update the receipt path.
                        updateReceiptQuery.setSQL("
                            UPDATE receipts
                            SET
                                FilePath = :receiptPath,
                                UploadDate = :formattedDate
                            WHERE transactionID = :transactionID
                        ");
                        updateReceiptQuery.addParam(name="receiptPath", value=receiptPath, cfsqltype="cf_sql_varchar");
                        updateReceiptQuery.addParam(name="transactionID", value=arguments.transactionID, cfsqltype="cf_sql_integer");
                        updateReceiptQuery.addParam(name="formattedDate", value=formattedDate, cfsqltype="cf_sql_varchar");

                        var updateResult = updateReceiptQuery.execute().getPrefix();

                        if (!updateResult.recordCount) {
                            result.success = false;
                            result.message = "Transaction updated, but receipt update failed.";
                        } else {
                            result.success = true;
                            result.message = "Receipt updated successfully.";
                        }
                    } else {
                        // If transactionID does not exist, insert a new receipt.
                        updateReceiptQuery.setSQL("
                            INSERT INTO receipts (transactionID, FilePath)
                            VALUES (:transactionID, :receiptPath)
                        ");
                        updateReceiptQuery.addParam(name="receiptPath", value=receiptPath, cfsqltype="cf_sql_varchar");
                        updateReceiptQuery.addParam(name="transactionID", value=arguments.transactionID, cfsqltype="cf_sql_integer");
                        var insertResult = updateReceiptQuery.execute().getPrefix();

                        if (insertResult.recordCount) {
                            result.success = true;
                            result.message = "Receipt added successfully.";
                        } else {
                            result.success = false;
                            result.message = "Failed to add new receipt.";
                        }
                    }
                } catch (any e) {
                    // Log any errors encountered during the receipt update or insertion.
                    writeLog(file="Database", text="Error handling receipt: " & e.message & "; Details: " & e.detail);
                    result.success = false;
                    result.message = "An error occurred while handling the receipt.";
                }
            }
        } catch (any e) {
            // Log any errors encountered during the transaction update.
            writeLog(file="Database", text="Error updating transaction: " & e.message & "; Details: " & e.detail);
            result.success = false;
            result.message = "Error updating transaction: " & e.message;
        }

        return result;  // Return a struct indicating the success or failure of the update operation.
    }

    /**
     * Retrieves a specific transaction by its ID, including category, description, date, amount, type, and receipt path.
     * @param numeric transactionID - The ID of the transaction to be retrieved.
     * @return array - An array of structs representing the transaction details.
     */
    public array function getTransactionByID(required numeric transactionID) {
        var transactions = [];  // Initialize an empty array to hold the transaction details.

        try {
            var query = new Query();
            query.setSQL("
                SELECT 
                    t.transactionID,
                    c.name AS category,
                    t.description,
                    t.date,
                    t.amount,
                    t.type,
                    r.FilePath
                FROM transactions t
                INNER JOIN categories c ON t.categoryID = c.categoryID
                LEFT JOIN Receipts r ON r.transactionID = t.transactionID
                WHERE t.transactionID = :transactionID
            ");
            query.addParam(name="transactionID", value=arguments.transactionID, cfsqltype="cf_sql_integer");

            var result = query.execute().getResult();

            // Convert query result to array of structs with transaction details.
            for (var row in result) {
                arrayAppend(transactions, {
                    transactionID: row.transactionID,
                    category: row.category,
                    description: row.description,
                    date: dateFormat(row.date, "yyyy-mm-dd"),  // Format the date as "yyyy-mm-dd".
                    amount: row.amount,
                    type: row.type,
                    filePath: row.FilePath
                });
            }
        } catch (any e) {
            // Log any errors encountered during the query execution.
            writeLog(file="Database", text="Error retrieving transaction by ID: " & e.message & "; Details: " & e.detail);
        }

        return transactions;  // Return the array of transaction details.
    }
    
    /**
     * Deletes a transaction by its ID and, if applicable, deletes the associated receipt within a transaction.
     * @param numeric transactionID - The ID of the transaction to be deleted.
     * @return struct - A struct indicating the success or failure of the delete operation.
     */
    public struct function deleteTransaction(
        required numeric transactionID
    ) {
        var result = {
            "success": false,
            "message": ""
        };

        transaction action="begin" {
            try {
                // Check if the transactionID exists in the receipts table
                var checkReceiptQuery = new Query();
                checkReceiptQuery.setDatasource("FinanceManager");
                checkReceiptQuery.setSQL("
                    SELECT COUNT(*) AS Count
                    FROM receipts
                    WHERE transactionID = :transactionID
                ");
                checkReceiptQuery.addParam(name="transactionID", value=arguments.transactionID, cfsqltype="cf_sql_integer");

                var checkReceiptResult = checkReceiptQuery.execute().getResult();

                // If the transactionID exists in the receipts table
                if (checkReceiptResult.Count > 0) {
                    // Step 1: Delete the associated receipt
                    var deleteReceiptQuery = new Query();
                    deleteReceiptQuery.setDatasource("FinanceManager");
                    deleteReceiptQuery.setSQL("
                        DELETE FROM receipts
                        WHERE transactionID = :transactionID
                    ");
                    deleteReceiptQuery.addParam(name="transactionID", value=arguments.transactionID, cfsqltype="cf_sql_integer");

                    deleteReceiptQuery.execute();
                }

                // Step 2: Delete the transaction
                var deleteTransactionQuery = new Query();
                deleteTransactionQuery.setDatasource("FinanceManager");
                deleteTransactionQuery.setSQL("
                    DELETE FROM transactions
                    WHERE transactionID = :transactionID
                ");
                deleteTransactionQuery.addParam(name="transactionID", value=arguments.transactionID, cfsqltype="cf_sql_integer");

                deleteTransactionQuery.execute();

                transaction action="commit";
                result.success = true;
                result.message = checkReceiptResult.Count > 0
                    ? "Transaction and associated receipt deleted successfully."
                    : "Transaction deleted successfully.";
            } catch (any e) {
                transaction action="rollback";
                writeLog(file="Database", text="Error deleting transaction: " & e.message & "; Details: " & e.detail);
                result.success = false;
                result.message = "Error deleting transaction: " & e.message;
            }
        }

        return result;  // Return a struct indicating the success or failure of the delete operation
    }

    /**
     * Retrieves transactions between two specified dates.
     * @param date fromDate - The start date for the range.
     * @param date toDate - The end date for the range.
     * @return array - An array of structs representing the transactions within the date range.
     */
    public array function getTransactionsBetweenDates(required date fromDate, required date toDate) {
        var transactions = [];
        var dateFormat = session.usersettings.dateFormat;  // Get the date format from user settings.

        try {
            var query = new Query();
            query.setSQL("
                SELECT 
                    t.transactionID,
                    t.date,
                    t.type,
                    t.description,
                    t.amount,
                    c.name AS category
                FROM transactions t
                INNER JOIN categories c ON t.categoryID = c.categoryID
                WHERE t.date BETWEEN :fromDate AND :toDate
                ORDER BY t.date DESC
            ");
            query.addParam(name="fromDate", value=arguments.fromDate, cfsqltype="cf_sql_date");
            query.addParam(name="toDate", value=arguments.toDate, cfsqltype="cf_sql_date");

            var result = query.execute().getResult();

            // Convert query result to array of structs with transaction details
            for (var row in result) {
                arrayAppend(transactions, {
                    transactionID: row.transactionID,
                    date: dateFormat(row.date, dateFormat),  // Format the date based on user settings.
                    type: row.type,
                    description: row.description,
                    amount: row.amount,
                    category: row.category
                });
            }
        } catch (any e) {
            // Log any errors encountered during the retrieval of transactions
            writeLog(file="Database", text="Error retrieving transactions: " & e.message & "; Details: " & e.detail);
        }

        return transactions;  // Return an array of structs representing the transactions within the date range.
    }

    /**
     * Formats a date according to a specified format.
     * @param date inputDate - The date to be formatted.
     * @param string format - The format to be applied to the date.
     * @return string - The formatted date as a string.
     */
    public string function formatDate(date inputDate, string format) {
        return dateFormat(inputDate, format);  // Format the date according to the specified format.
    }
    
    

}

                
            
            
    


