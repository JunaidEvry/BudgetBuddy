component output="false" {

    /**
     * Checks if a category exists for a given user and type, and adds it if it doesn't exist.
     * @param type (required) - The type of the category (e.g., expense or income).
     * @param category (required) - The name of the category to check/add.
     * @return A struct containing the success status and a message.
     */
    public struct function addCategory(
        string type,  
        string category
        ) returnFormat="json" {
        
        var response = {
            "success": false,
            "message": ""
        };
        
        var userId = session.userID;

        try {
            var query = new Query();
            
            query.setSQL("
                INSERT INTO categories (userID, type, Name)
                SELECT :userID, :type, :category
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM categories
                    WHERE userID = :userID
                      AND type = :type
                      AND Name = :category
                )
            ");
            query.addParam(name="userID", value=userID, cfsqltype="cf_sql_integer");
            query.addParam(name="type", value=arguments.type, cfsqltype="cf_sql_varchar");
            query.addParam(name="category", value=arguments.category, cfsqltype="cf_sql_varchar");

            var result = query.execute().getPrefix();
            
            // Check if any rows were affected by the INSERT
            if (result.recordCount > 0) {
                response.success = true;
                response.message = "Category added successfully.";
            } else {
                response.message = "Category already exists.";
            }

        } catch (any e) {
            response.message = "Failed to add category. Error: " & e.message;
            writeLog(file="Database", text="Error in addCategory function: " & e.message & "; Details: " & e.detail);
        }

        return response;
    }

    /**
     * Retrieves categories for a specific user.
     * @param userID (required) - The ID of the user.
     * @return A structure containing success status, a message, and an array of categories.
     */
    public struct function getCategoriesByUserID(string userID) {
        var result = { 
            success = false, 
            message = "", 
            data = [] 
        };

        try {
            var categoryQuery = new Query(
                datasource = "FinanceManager",
                sql = "
                    SELECT 
                        categoryId AS id,
                        name AS name,
                        type AS type
                    FROM 
                        categories
                    WHERE 
                        userID = :userID
                "
            );
            categoryQuery.addParam(name="userID", value=userID, cfsqltype="cf_sql_integer");
            var queryResult = categoryQuery.execute().getResult();

            if (queryResult.recordcount > 0) {
                for (var row in queryResult) {
                    arrayAppend(result.data, {
                        id = row.id,
                        name = row.name,
                        type = row.type
                    });
                }
                result.success = true;
            } else {
                result.message = "No categories found for this user.";
            }
        } catch (any e) {
            writeLog(file="Database", text="Error fetching categories by user ID: " & e.message & "; Details: " & e.detail);
            result.message = "An error occurred while fetching the categories: " & e.message;
        }

        return result;
    }

    /**
     * Updates the name of an existing category.
     * @param userID (required) - The ID of the user.
     * @param id (required) - The ID of the category to update.
     * @param name (required) - The new name for the category.
     * @return A boolean indicating the success of the operation.
     */
    public boolean function updateCategory(string userID, numeric id, string name) {
        try {
            var query = new Query();
            
            query.setSQL("
                UPDATE categories
                SET name = :name
                WHERE userID = :userID AND categoryId = :id
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");
            query.addParam(name="id", value=arguments.id, cfsqltype="cf_sql_integer");
            query.addParam(name="name", value=arguments.name, cfsqltype="cf_sql_varchar");
            query.execute();
        } catch (any e) {
            writeLog(file="Database", text="Error updating category: " & e.message & "; Details: " & e.detail);
            return false;
        }
        return true;
    }

    /**
     * Retrieves category names for a specific user and type.
     * @param userID (required) - The ID of the user.
     * @param type (required) - The type of the category (e.g., expense or income).
     * @return A structure containing an array of category names.
     */
    public struct function getCategoriesByType(required string userID, required string type) {
        var categories = {
            categories = []
        };

        try {
            var query = new Query();
            
            query.setSQL("
                SELECT Name
                FROM categories
                WHERE userID = :userID
                AND type = :type
            ");
            query.addParam(name="userID", value=arguments.userID, cfsqltype="cf_sql_integer");
            query.addParam(name="type", value=arguments.type, cfsqltype="cf_sql_varchar");

            var result = query.execute().getResult();

            for (var row in result) {
                arrayAppend(categories.categories, row.Name);
            }
        } catch (any e) {
            writeLog(file="Database", text="Error retrieving categories by type: " & e.message & "; Details: " & e.detail);
            // Optionally handle or re-throw the exception here
        }

        return categories;
    }

    /**
     * Deletes a category and its associated records within a transaction.
     * @param categoryID (required) - The ID of the category to delete.
     * @return A struct containing the success status and a message.
     */
    public struct function deleteCategoryWithAssociations(required numeric categoryID) {
        var response = {
            "success": false,
            "message": ""
        };

        transaction action="begin" {
            try {
                // Delete receipts associated with the transactions of the category
                var deleteReceiptsQuery = new Query();
                deleteReceiptsQuery.setDatasource("FinanceManager");
                deleteReceiptsQuery.setSQL("
                    DELETE FROM Receipts 
                    WHERE TransactionID IN (
                        SELECT TransactionID 
                        FROM Transactions 
                        WHERE CategoryID = :categoryID
                    )
                ");
                deleteReceiptsQuery.addParam(name="categoryID", value=arguments.categoryID, cfsqltype="cf_sql_integer");
                deleteReceiptsQuery.execute();

                // Delete transactions of the category
                var deleteTransactionsQuery = new Query();
                deleteTransactionsQuery.setDatasource("FinanceManager");
                deleteTransactionsQuery.setSQL("
                    DELETE FROM Transactions 
                    WHERE CategoryID = :categoryID
                ");
                deleteTransactionsQuery.addParam(name="categoryID", value=arguments.categoryID, cfsqltype="cf_sql_integer");
                deleteTransactionsQuery.execute();

                // Delete the category itself
                var deleteCategoryQuery = new Query();
                deleteCategoryQuery.setDatasource("FinanceManager");
                deleteCategoryQuery.setSQL("
                    DELETE FROM Categories 
                    WHERE CategoryID = :categoryID
                ");
                deleteCategoryQuery.addParam(name="categoryID", value=arguments.categoryID, cfsqltype="cf_sql_integer");
                deleteCategoryQuery.execute();

                transaction action="commit";
                response.success = true;
                response.message = "Category and associated records deleted successfully.";
            } catch (any e) {
                transaction action="rollback";
                response.message = "Error deleting category and associated records: " & e.message & "; Details: " & e.detail;
                writeLog(file="Database", text="Error in deleteCategoryWithAssociations: " & e.message & "; Details: " & e.detail);
            }
        }

        return response;
    }
}
