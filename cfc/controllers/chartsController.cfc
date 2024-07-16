component output="false" {
    
    /**
     * Fetch weekly data for expenses and income.
     * @param weekStart (required) - The start date of the week.
     * @return A JSON structure containing success status and weekly data for expenses and income.
     */
    remote struct function getWeeklyData(
        required string weekStart
        ) returnFormat="json" {
        
        var result = { 
            "success" = false, 
            "data" = { 
                "expenses" = [], 
                "income" = [] 
            } 
        };
        
        try {
            var userID = session.userID;
            var transactionDAO = new cfc.models.transactionDao();
            var weekStartDate = parseDateTime(arguments.weekStart);
            
            // Fetch weekly expenses and income from the DAO
            result.data.expenses = transactionDAO.getWeeklyExpenses(userID, weekStartDate);
            result.data.income = transactionDAO.getWeeklyIncome(userID, weekStartDate);
            result.success = true;
        } catch (any e) {
            writeLog(file="Database", text="Error fetching weekly data: " & e.message & "; Details: " & e.detail);
            result.message = "Error fetching weekly data: " & e.message;
        }
        
        return result;
    }

    /**
     * Fetch yearly data for expenses and income.
     * @return A JSON structure containing success status and yearly data for expenses and income.
     */
    remote struct function getYearlyData() returnFormat="json" {
        
        var result = {
            "success": false,
            "data": {
                "income": [],
                "expense": []
            },
            "message": ""
        };
        
        try {
            var userID = session.userID;
            var transactionDAO = new cfc.models.transactionDAO();
            
            // Fetch yearly income and expense data from the DAO
            result.data.income = transactionDAO.getYearlyIncomeData(userID);
            result.data.expense = transactionDAO.getYearlyExpenseData(userID);
            result.success = true;
        } catch (any e) {
            writeLog(file="Database", text="Error fetching yearly data: " & e.message & "; Details: " & e.detail);
            result.message = "Error fetching yearly data: " & e.message;
        }
        
        return result;
    }

    /**
     * Fetch monthly data for expenses or income.
     * @param month (required) - The month for which data is to be fetched.
     * @param year (required) - The year for which data is to be fetched.
     * @param type (required) - The type of data to fetch (income or expense).
     * @return A JSON structure containing success status and monthly data.
     */
    remote struct function getMonthlyData(
        numeric month,
        numeric year,
        string type
        ) returnFormat="json" {
        
        var response = { 
            "success": false, 
            "data": {} 
        };
        
        try {
            var transactionDAO = new cfc.models.transactionDAO();
            var userID = session.userID;
            
            // Fetch monthly data from the DAO
            var monthlyData = transactionDAO.getMonthlyData(userID, month, year, type);
            response.success = true;
            response.data = monthlyData;
        } catch (any e) {
            writeLog(file="Database", text="Error fetching monthly data: " & e.message & "; Details: " & e.detail);
            response.message = "Error fetching monthly data: " & e.message;
        }
        
        return response;
    }
}
