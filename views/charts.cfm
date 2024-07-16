<cfinclude template="../headerLibraries.cfm"/>
<div class="pagetitle">
  <h1>Charts and Graphs</h1>
  <nav>
    <ol class="breadcrumb">
      <li class="breadcrumb-item"><a href="../index.cfm">Home</a></li>
      <li class="breadcrumb-item active">Charts and Graphs</li>
    </ol>
  </nav>
</div>

<div class="row">
  <div class="col-lg-6">
    <div class="card">
      <div class="card-body">
        <h5 class="card-title">Weekly Analysis</h5>
        <div class="filter">
          <button id="prevWeek" class="btn btn-primary mt-4">Previous Week</button>
          
          <button id="nextWeek" class="btn btn-primary  mt-4">Next Week</button>

        </div>
        
        <span id="dateRange" class="fw-bold fw-light mt-4 mx-3"></span>
      

        <!-- Bar Chart -->
        <div id="barChart" style="min-height: 400px;" class="echart">

        </div>
      
        <!-- End Bar Chart -->
      </div>
    </div>
  </div>



  <div class="col-lg-6">
    <div class="card">
        <div class="card-body">
            <div class="filter">
                <button id="prevMonth" class="btn btn-primary mt-4">Previous Month</button>
                <button id="nextMonth" class="btn btn-primary mt-4">Next Month</button>
                <select id="monthSelect" class="form-select mt-2">
                    <option value="1">January</option>
                    <option value="2">February</option>
                    <option value="3">March</option>
                    <option value="4">April</option>
                    <option value="5">May</option>
                    <option value="6">June</option>
                    <option value="7">July</option>
                    <option value="8">August</option>
                    <option value="9">September</option>
                    <option value="10">October</option>
                    <option value="11">November</option>
                    <option value="12">December</option>
                </select>
                <select id="yearSelect" class="form-select mt-2">
                    <!-- JavaScript will populate this -->
                </select>
                <select id="typeSelect" class="form-select mt-2">
                    <option value="Income">Income</option>
                    <option value="Expense">Expense</option>
                </select>
            </div>
            <h5 class="card-title mt-4">Monthly Distribution Pie Chart</h5>
            <!-- Pie Chart -->
            <div id="pieChart">

            </div>
            <!-- End Pie Chart -->
        </div>
    </div>
</div>

<div class="col-lg-12">
  <div class="card">
      <div class="card-body">
          <h5 class="card-title">Yearly Comparision</h5>
          <!-- Line Chart -->
          <div id="lineChart">

          </div>
          <!-- End Line Chart -->
      </div>
  </div>
  <script src="../assets/js/charts.js"></script>

<cfinclude template="../footerLibraries.cfm"/>