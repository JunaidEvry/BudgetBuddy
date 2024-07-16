<cfinclude template="../headerLibraries.cfm"/>

<div class="pagetitle">
	<div>
		<h1>All Transactions</h1>
		<nav>
			<ol class="breadcrumb">
				<li class="breadcrumb-item"><a href="index.cfm">Home</a></li>
				<li class="breadcrumb-item active">All Transactions</li>
			</ol>
		</nav>
	</div>
</div>
<!--dropdown-->
<section class="section">
	<div class="row">
		<div class="col-lg-12">
			<div class="card">
				<div class="card-body">
					<div class="pd-2">
						<!-- Filter Dropdown -->
					</div>
				</div>
				<div id="message" class="alert" style="display:none;"></div>
				<div id="transaction-container" class="card-body"></div>
				<div id="modalPlaceholder"></div>
				<div id="confirmDeleteModal" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="confirmDeleteModalLabel" aria-hidden="true">
					<div class="modal-dialog modal-dialog-centered" role="document">
						<div class="modal-content">
							<div class="modal-header">
								<h5 class="modal-title" id="confirmDeleteModalLabel">Confirm Deletion</h5>
								
							</div>
							<div class="modal-body">
								Are you sure you want to delete this transaction?
							</div>
							<div class="modal-footer">
								<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
								<button type="button" class="btn btn-danger" id="confirmDeleteBtn">Delete</button>
							</div>
						</div>
					</div>
				</div>
				
			</div>
		</div>
	</div>
</section>
<script src="../assets/js/transactionList.js"></script>

<cfinclude template="../footerLibraries.cfm"/>
