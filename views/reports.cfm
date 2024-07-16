<cfinclude template="../headerLibraries.cfm"/>
    <div class="pagetitle d-flex flex-row align-items-start justify-content-between mt-3 mb-1">
      <div>
        <h1>Generate Reports</h1>
        <nav>
          <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="../index.cfm">Home</a></li>
            <li class="breadcrumb-item active">Reports</li>
          </ol>
        </nav>
      </div>
    </div>

    <div class="row">
      <div class="col-md-4">
        <div id="reportMessage" class="alert" style="display:none;"></div>
        <form  class="g-3">
          <div class="col-md-12 mb-3">
            <div class="form-floating">
              <input type="date" class="form-control" id="floatingFromDate" name="fromDate" placeholder="Date">
              <label for="floatingFromDate"><p>From Date<p></label>
            </div>
          </div>
          <div class="col-md-12 mb-3">
            <div class="form-floating">
              <input type="date" class="form-control" id="floatingToDate" name="toDate" placeholder="Date">
              <label for="floatingToDate">To Date</label>
            </div>
          </div>
          <div class="col-md-12 mb-3">
            <div class="form-floating mb-3">
              <select class="form-select" id="floatingType" name="fileType" aria-label="Type of File">
                <option value="pdf" selected>PDF</option>
                <option value="excel">Excel</option>
                <option value="csv">CSV</option>
              </select>
              <label for="floatingType">Type</label>
            </div>
          </div>
          <div class="col-md-12 text-center mb-3">
            <button id="reportFormBtn" class="btn btn-primary">Generate Report</button>
          </div>
        </form>
        
      </div>
    </div>
    <script src="../assets/js/reports.js"></script>

<cfinclude template="../footerLibraries.cfm"/>