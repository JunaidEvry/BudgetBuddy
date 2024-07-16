component output="false" {

    /**
     * Generates a report for transactions between specified dates in the specified file type.
     * @param fromDate (required) - The start date for the report.
     * @param toDate (required) - The end date for the report.
     * @param fileType (required) - The file type for the report (e.g., pdf, csv, excel).
     * @return A JSON structure containing success status, a message, and the URL of the generated file.
     */
    remote struct function generateReport(
        required date fromDate, 
        required date toDate, 
        required string fileType
        ) returnFormat="json" {
        
        var result = { 
            "success": false, 
            "message": "", 
            "fileURL": "" 
        };

        try {
            // Call the DAO to get transactions between the specified dates
            var transactionDAO = new cfc.models.transactionDAO();
            var transactions = transactionDAO.getTransactionsBetweenDates(arguments.fromDate, arguments.toDate);

            // Generate the report
            var fileURL = generateReportFile(transactions, arguments.fileType);
            result.success = true;
            result.fileURL = fileURL;
        } catch (any e) {
            writeLog(file="Database", text="Error generating report: " & e.message & "; Details: " & e.detail);
            result.message = "Error generating report: " & e.message;
        }

        return result;
    }

    /**
     * Generates a report file based on the given transactions and file type.
     * @param transactions (required) - The list of transactions to include in the report.
     * @param fileType (required) - The file type for the report (e.g., pdf, csv, excel).
     * @return The URL of the generated file.
     */
    private string function generateReportFile(
        array transactions, 
        string fileType
        ) {
        
        var dateFormat = session.usersettings.dateFormat;
        var filePath = "";
        var fileName = "TransactionReport_" & dateFormat(now(), "yyyymmdd") & "_" & timeFormat(now(), "HHMMSS") & "." & fileType;

        if (fileType == "pdf") {
            filePath = expandPath("../../reports/pdf/") & fileName;

            var head = '
                <head>
                    <style>
                        table {
                            border-collapse: collapse;
                            width: 100%;
                            border: 1px solid black;
                        }
                        th {
                            text-align: left;
                        }
                        td, th {
                            border: 1px solid black;
                        }
                    </style>
                </head>
                <body>
                    <h1>Transaction Report</h1>
                    <table>
                        <tr>
                            <th>Transaction ID</th>
                            <th>Date</th>
                            <th>Type</th>
                            <th>Description</th>
                            <th>Amount</th>
                            <th>Category</th>
                        </tr>
            ';

            var table = "";
            for (var transaction in transactions) {
                table &= "<tr>";
                table &= "<td>#transaction.transactionID#</td>";
                table &= "<td>#dateFormat(transaction.date, dateFormat)#</td>";
                table &= "<td>#transaction.type#</td>";
                table &= "<td>#transaction.description#</td>";
                table &= "<td>#transaction.amount#</td>";
                table &= "<td>#transaction.category#</td>";
                table &= "</tr>";
            }

            table &= "</table></body>";

            cfhtmltopdf(destination=filePath, overwrite="yes") {
                writeOutput(head & table);
            }
            return "/Assignments/Mini_Project/reports/pdf/" & fileName;

        } else if (fileType == "csv") {
            filePath = expandPath("../../reports/csv/") & fileName;
            var csvData = "Transaction ID,Date,Type,Description,Amount,Category\n";
            for (var transaction in transactions) {
                csvData &= "#transaction.transactionID#,#dateFormat(transaction.date, dateFormat)#,#transaction.type#,#transaction.description#,#transaction.amount#,#transaction.category#\n";
            }
            fileWrite(filePath, csvData);
            return "/Assignments/Mini_Project/reports/csv/" & fileName;

        } else if (fileType == "excel") {
            fileName = "TransactionReport_" & dateFormat(now(), "yyyymmdd") & "_" & timeFormat(now(), "HHMMSS") & ".xls";
            filePath = expandPath("../../reports/excel/") & fileName;
            
            // Create Excel sheet and add data
            var spreadsheet = spreadsheetNew("Transaction Report", true);
            spreadsheetAddRow(spreadsheet, "Transaction ID,Date,Type,Description,Amount,Category");
            for (var transaction in transactions) {
                var arrayData = [
                    transaction.transactionID,
                    dateFormat(transaction.date, dateFormat),
                    transaction.type,
                    transaction.description,
                    transaction.amount,
                    transaction.category
                ];
                spreadsheetAddRow(spreadsheet, arrayData.toList());
            }
            spreadsheetWrite(spreadsheet, filePath, true);
            
            return "/Assignments/Mini_Project/reports/excel/" & fileName;
        }
        return "/Assignments/Mini_Project/reports/excel/" & fileName;
    }
}
