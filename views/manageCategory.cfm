<cfinclude template="../headerLibraries.cfm"/>
<div class="pagetitle d-flex flex-row align-items-start justify-content-between mt-3 mb-1">
  <div>
    <h1>Manage Categories</h1>
    <nav>
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><a href="../index.cfm">Home</a></li>
        <li class="breadcrumb-item active">Manage Categories</li>
      </ol>
    </nav>
  </div>
  <button type="button" class="btn btn-primary" id="newCategoryBtn">
    <i class="bi bi-plus-square-fill"></i> Add New Category
  </button>
</div><!-- End Page Title -->

<section class="section dashboard">
  <div class="btn-group">
    <button type="button" class="btn btn-secondary dropdown-toggle" id="dropdownMenuButton">
      Select Type
    </button>
    <div class="dropdown-menu" id="dropdownItems">
      <a class="dropdown-item" href="#" data-type="Income">Income</a>
      <a class="dropdown-item" href="#" data-type="Expense">Expense</a>
    </div>
  </div>
  <div class="row">
    <!-- Left side columns -->
    <div class="col-lg-12">
      <div class="row">
        <h5 class="card-title">Category List</h5>
        <table class="table table-hover" id="myTable">
          <thead>
            <tr>
              <th scope="col">#</th>
              <th scope="col">Category Name</th>
              <th scope="col">Type</th>
              <th scope="col">Update</th>
              <th scope="col">Delete</th>
            </tr>
          </thead>
          <tbody>
            <!-- Categories will be rendered here -->
          </tbody>
        </table>

        <div class="modal fade" id="verticalycentered1" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-body">
                <div class="card-body">
                  <h5 class="card-title">Add New Category</h5>
                  <!-- Floating Labels Form -->
                  <form class="row g-3">
                    <div id="message" class="alert" style="display: none;"></div>
                    <div class="col-md-12">
                      <div class="form-floating">
                        <select class="form-select" id="floatingType" aria-label="Type" required>
                          <option value="Income" selected>Income</option>
                          <option value="Expense">Expense</option>
                        </select>
                        <label class="floatingLabel" for="floatingType">Type</label>
                      </div>
                    </div>
                    <div class="col-md-12">
                      <div class="form-floating">
                        <input type="text" class="form-control" id="floatingCategory" placeholder="New Category" value="" required>
                        <label class="floatingLabel" for="floatingCategory">New Category</label>
                      </div>
                    </div>
                    <div class="text-center">
                      <button id="submitAddCategory" class="btn btn-primary">Add Category</button>
                    </div>
                  </form>
                  <!-- End Floating Labels Form -->
                </div>
              </div>
            </div>
          </div>
        </div><!-- End Vertically Centered Modal -->

        <!-- Update Category Modal -->
        <div class="modal fade" id="updateCategoryModal" tabindex="-1" role="dialog" aria-labelledby="updateModalLabel" aria-hidden="true">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="modal-body">
                <div class="card-body">
                  <h5 class="card-title">Update Category</h5>
                  <form class="row g-3" id="updateCategoryForm">
                    <div id="updateMessage" class="alert" style="display: none;"></div>
                    <input type="hidden" id="updateCategoryId">
                    <div class="col-md-12">
                      <div class="form-floating">
                        <input type="text" class="form-control" id="updateCategoryName" placeholder="Category Name" required>
                        <label for="updateCategoryName">Category Name</label>
                      </div>
                    </div>
                    <div class="text-center">
                      <button type="submit" class="btn btn-primary">Update Category</button>
                    </div>
                  </form>
                </div>
              </div>
            </div>
          </div>
        </div><!-- End Update Category Modal -->
        <div class="modal fade" id="deleteCategory" tabindex="-1">
          <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
              <div class="card-body">
                

                <h5 class="card-title">Delete Category</h5>
                <div id="deleteMessage" class="alert" style="display: none;"></div>
                
                <p calss="card-text"> While deleting the category all the associated transactions and receipts will also be deleted. Are you sure you want to delete?
                </p>
                <div class="modal-footer">
                  <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                  <button type="button" class="btn btn-danger" id="confirmDelete">Delete</button>
                </div>
              </div>

            </div>
          </div>
        </div><!-- End Vertically centered Modal-->
        
      </div>
    </div><!-- End Left side columns -->
  </div>
</section>

<script src="../assets/js/manageCategory.js"></script>

<cfinclude template="../footerLibraries.cfm"/>
