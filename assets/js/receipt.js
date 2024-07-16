$(document).ready(function() {
    console.log("hi");
  loadReceipts();
   
});
function loadReceipts(){
    $.ajax({
        url:'../cfc/controllers/receiptController.cfc?method=getReceipts',
        method: 'GET', 
        success: function(response) {
            var result = JSON.parse(response);
            if (result.SUCCESS) {
                Handlebars.registerHelper('incrementIndex', function(value) {
                    return parseInt(value) + 1;
                  });
                // Load the Handlebars template
                $.ajax({
                    url: '../templates/receiptList.hbs',
                    success: function(templateSource) {
                        // Compile the Handlebars template
                        var template = Handlebars.compile(templateSource);
                        
                        // Render the receipts data into the template
                        var html = template({ receipts: result.RECEIPTS});
                        
                        $('#myTable').DataTable().destroy();
                        // Insert the rendered HTML into the DOM
                        $('#receiptsTableBody').html(html);
                        $('#myTable').DataTable();
                    },
                    error: function(xhr, status, error) {
                        console.error('Error loading template:', error);
                        alert('An error occurred while loading the template.');
                    }
                });
            } else {
                alert('Error fetching receipts: ' + result.MESSAGE);
            }
        },
        error: function(xhr, status, error) {
        
        }
    });
}


function deleteReceipt(receiptID) {
    currentReceiptID = receiptID;  // Store the current receipt ID

    // Show the custom confirmation modal
    $('#confirmDeleteReceiptModal').modal('show');

    // Handle the deletion confirmation
    $('#confirmDeleteReceiptBtn').off('click').on('click', function () {
        $('#confirmDeleteReceiptModal').modal('hide');  // Hide the modal
        $.ajax({
            url: '../cfc/controllers/receiptController.cfc?method=deleteReceipt',
            method: 'POST',
            data: { receiptID: currentReceiptID },
            success: function(response) {
                console.log(response);
                var result = response;
                if (result) {
                    $('#deleteRecieptmessage').removeClass('alert-danger').addClass('alert-success').text("Deleted Receipt Successfully").show();
                    setTimeout(() => {
                        $('#deleteRecieptmessage').removeClass('alert-danger').addClass('alert-success').text("Deleted Receipt Successfully").hide();
                        // Optionally refresh the transaction list or table
                        loadTransactionTable();
                    }, 2000);
                    // Remove the row from the table
                    $('tr[data-receipt-id="' + currentReceiptID + '"]').remove();
                    loadReceipts();  // Refresh the receipts table
                } else {
                    $('#deleteRecieptmessage').removeClass('alert-success').addClass('alert-danger').text("Could not delete the receipt.Please try again later.").show();
                }
            },
            error: function(xhr, status, error) {
                console.error('Error deleting receipt:', error);
              
            }
        });
    })
}

function downloadReceipt(filePath) {
    // Implement download functionality
    window.open(filePath, '_blank');
}