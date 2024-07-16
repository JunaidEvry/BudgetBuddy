component output="false" {

	 /**
     * Adds a new category for the current user.
     * @param type (required) - The type of the category (e.g., expense or income).
     * @param category (required) - The name of the new category.
     * @return A struct containing the success status and a message.
     */
    remote struct function addCategory(
        string type,  
        string category
        ) returnFormat="json" {
        
        var response = {
            "success": false,
            "message": ""
        };
        
        // Get the userID from the session
        var userId = session.userID;

        try {
            // Create an instance of the CategoryDao
            var categoryDao = new cfc.models.categoryDao();
            
            // Call the addCategory method
            response = categoryDao.addCategory(type=arguments.type, category=arguments.category);

        } catch (any e) {
            response.message = "Failed to add category. Error: " & e.message;
            writeLog(file="Database", text="Error in addCategory method: " & e.message & "; Details: " & e.detail);
        }

        return response;
    }
    /**
     * Retrieves all categories for the user.
     * @return A JSON structure containing the user's categories.
     */
    remote struct function getCategories() returnFormat="json" {
        
        var userId = session.userID;
        var categoryDao = new cfc.models.categoryDao();
        
        // Fetch categories for the user
        var result = categoryDao.getCategoriesByUserID(userId);
        
        return result;
    }
    
    /**
     * Updates an existing category for the user.
     * @param id (required) - The ID of the category to update.
     * @param name (required) - The new name of the category.
     * @return A JSON structure containing success status and a message.
     */
    remote struct function updateCategory(
        numeric id, 
        string name
        ) returnFormat="json" {
        
        var response = {
            "success": false,
            "message": ""
        };
        
        var userId = session.userID;
        var categoryDao = new cfc.models.categoryDao();
        
        // Update the category
        var result = categoryDao.updateCategory(userId, id, name);
        if (result) {
            response.success = true;
            response.message = "Category updated successfully.";
        } else {
            response.message = "Category already exists.";
        }
        
        return response;
    }
    
    /**
     * Retrieves categories by type for the user.
     * @param type (required) - The type of the categories (e.g., income, expense).
     * @return A JSON structure containing categories of the specified type.
     */
    remote struct function getCategoriesByType(
        required string type
        ) returnFormat="json" {
        
        var categoryDao = new cfc.models.categoryDao();
        var userId = session.userID;
        
        // Fetch categories by type for the user
        return categoryDao.getCategoriesByType(userId, arguments.type);
    }
    
    /**
     * Deletes a category and its associated records.
     * @param categoryID (required) - The ID of the category to delete.
     * @return A struct containing the success status and a message.
     */
    remote struct function deleteCategoryWithAssociations(required numeric categoryID) returnFormat="json"{
        var response = {
            "success": false,
            "message": ""
        };

        try {
            var categoryDao = new cfc.models.categoryDao();
            response = categoryDao.deleteCategoryWithAssociations(categoryID=arguments.categoryID);
        } catch (any e) {
            response.message = "Failed to delete category. Error: " & e.message;
            writeLog(file="Database", text="Error in deleteCategoryWithAssociations method: " & e.message & "; Details: " & e.detail);
        }

        return response;
    }
}
