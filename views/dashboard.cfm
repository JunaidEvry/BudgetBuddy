<cfinclude template="../headerLibraries.cfm"/>
<div class="pagetitle d-flex flex-row align-items-smanageCategory.cfmtart justify-content-between mt-3 mb-1" data-bs-theme="dark">
  <div>
	<h1>Dashboard</h1>
	<nav>
	  <ol class="breadcrumb">
		<li class="breadcrumb-item"><a href="index.cfm">Home</a></li>
		<li class="breadcrumb-item active">Dashboard</li>
	  </ol>
	</nav>
  </div>
  <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#verticalycentered">
	<i class="bi bi-plus-square-fill"></i> Add New Transaction
  </button>
 
</div><!-- End Page Title -->

<section class="section dashboard" >
  <div class="row">
	<!-- Left side columns -->
	<div class="col-lg-6">
	  <div class="row">
		<h5 class="card-title">Recent Transactions</h5>
		<div id="recentTransactionsPlaceholder"></div>
		<div id="modalPlaceholder"></div>
	  </div>
	</div><!-- End Left side columns -->

	<!-- Right side columns -->
	<div class="col-lg-6">
	  <div class="card">
		<div class="card-body mt12">
		  <h5 class="card-title">Expense</h5>
		  <div class="filter">
			<a class="icon" href="#" data-bs-toggle="dropdown"><i class="bi bi-three-dots"></i></a>
			<ul class="dropdown-menu dropdown-menu-end dropdown-menu-arrow">
			  <li class="dropdown-header text-start">
				<h6>Filter</h6>
			  </li>
			  <li><a class="dropdown-item" href="#">Today</a></li>
			  <li><a class="dropdown-item" href="#">This Month</a></li>
			  <li><a class="dropdown-item" href="#">This Year</a></li>
			</ul>
		  </div>

		  <!-- Expense Pie Chart -->
		  <div id="pieChart"></div>


		</div>
	  </div>

	  <!-- Income Pie Chart -->
	  <div class="card">
		<div class="card-body">
		  <h5 class="card-title">Income</h5>
		  <div class="filter">
			<a class="icon" href="#" data-bs-toggle="dropdown"><i class="bi bi-three-dots"></i></a>
			<ul class="dropdown-menu dropdown-menu-end dropdown-menu-arrow">
			  <li class="dropdown-header text-start">
				<h6>Filter</h6>
			  </li>
			  <li><a class="dropdown-item" href="#">Today</a></li>
			  <li><a class="dropdown-item" href="#">This Month</a></li>
			  <li><a class="dropdown-item" href="#">This Year</a></li>
			</ul>
		  </div>

		  <!-- Income Pie Chart -->
		  <div id="pieChart2"></div>

		 
		  <!-- End Income Pie Chart -->

		</div>
	  </div>
	</div><!-- End Right side columns -->
  </div>
</section>
<cfoutput>

</cfoutput>
<script src="assets/js/addTransaction.js"></script>
<cfinclude template="../footerLibraries.cfm"/>
