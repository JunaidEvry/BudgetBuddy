<cfinclude template="../headerLibraries.cfm"/>
    <div class="pagetitle d-flex flex-row align-items-start justify-content-between mt-3 mb-1">
      <div>
        <h1>Manage Reciepts</h1>
        <nav>
          <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="../index.cfm">Home</a></li>
            <li class="breadcrumb-item active">Manage Reciepts</li>
          </ol>
        </nav>
      </div>
    </div>
    <div id="deleteRecieptmessage" class="alert" style="display:none;"></div>

    <table class="table table-hover" id="myTable">
      <thead>
          <tr>
              <th>#ReceiptID</th>
              <th data-type="date" data-format="YYYY/DD/MM">Date</th>
              <th>Category</th>
              <th>Amount (<cfoutput>#session.usersettings.currency#</cfoutput>)</th>
              <th>Type</th>
              <th>Delete</th>
              <th>Preview</th>
          </tr>
      </thead>
      <tbody id="receiptsTableBody">
          <!-- Handlebars template will render here -->
      </tbody>
  </table>
  <div id="confirmDeleteReceiptModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="confirmDeleteModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="confirmDeleteModalLabel">Confirm Deletion</h5>
          
        </div>
        <div class="modal-body">
          Are you sure you want to delete this Receipt?
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
          <button type="button" class="btn btn-danger" id="confirmDeleteReceiptBtn">Delete</button>
        </div>
      </div>
    </div>
  </div>
  <script src="../assets/js/receipt.js"></script>

  <cfinclude template="../footerLibraries.cfm"/>