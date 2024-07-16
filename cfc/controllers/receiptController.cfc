component output="false" {

    /**
     * Fetches all receipts for the user.
     * @return A JSON structure containing success status and the user's receipts.
     */
    remote struct function getReceipts() returnFormat="json" {
        var result = {};
        var receipts = [];
        var userID = session.userID;
        
        try {
            var receiptDAO = new cfc.models.receiptDAO();
            
            // Fetch receipts for the user
            receipts = receiptDAO.getReceiptsByUserID(userID);
            result.SUCCESS = true;
            result.receipts = receipts;
        } catch (any e) {
            result.SUCCESS = false;
            result.MESSAGE = "Error fetching receipts: " & e.message;
            writeLog(file="Database", text="Error fetching receipts: " & e.message & "; Details: " & e.detail);
        }
        
        return result;
    }

    /**
     * Deletes a receipt by its ID.
     * @param receiptID (required) - The ID of the receipt to delete.
     * @return A boolean indicating whether the receipt was successfully deleted.
     */
    remote boolean function deleteReceipt(
        required numeric receiptID
        ) returnFormat="json" {
        
        var success = false;
        
        try {
            // Instantiate the ReceiptDAO
            var receiptDAO = new cfc.models.receiptDAO();
            
            // Call the DAO method to delete the receipt
            success = receiptDAO.deleteReceipt(receiptID);
        } catch (any e) {
            writeLog(file="Database", text="Error deleting receipt: " & e.message & "; Details: " & e.detail);
        }
        
        return success;
    }
}
