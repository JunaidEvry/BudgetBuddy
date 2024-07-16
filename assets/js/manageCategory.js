$(document).ready(function() {
  // Fetch and compile the Handlebars template
  function getCategoryTemplate(Data) {
      $.ajax({
          url: '../templates/categoryTemplate.hbs', // Path to your Handlebars template
          method: 'GET',
          success: function(templateSource) {
              var template = Handlebars.compile(templateSource);
              var html = template(Data);
              $("#myTable tbody").html(html);
              $('#myTable').DataTable();
          },
          error: function() {
              $('#message').removeClass('alert-success').addClass('alert-danger').text('An error occurred while loading the template.').show();
          }
      });
  }

  // Show the add category modal
  $('#newCategoryBtn').click(function(e) {
      e.preventDefault();
      $('#verticalycentered1').modal('show');
  });

  // Load categories and render using the template
  function loadCategories() {
      $.ajax({
          url: '../cfc/controllers/categoryController.cfc?method=getCategories',
          method: 'POST',
          success: function(response) {
              var result = JSON.parse(response);
              if (result.SUCCESS) {
                  getCategoryTemplate(result.DATA);
              }
          },
          error: function() {
              $('#message').removeClass('alert-success').addClass('alert-danger').text('An error occurred while fetching categories.').show();
          }
      });
  }

  // Custom dropdown functionality
  $('#dropdownMenuButton').on('click', function() {
      $('#dropdownItems').toggle();
  });

  $('#dropdownItems').on('click', '.dropdown-item', function() {
      var selectedType = $(this).data('type');
      $('#dropdownMenuButton').text(selectedType);
      filterCategories(selectedType);
      $('#dropdownItems').hide();
  });

  // Filter categories based on type
  function filterCategories(type) {
      $('#myTable tbody tr').each(function() {
          var rowType = $(this).data('type');
          if (rowType === type || type === "All") {
              $(this).show();
          } else {
              $(this).hide();
          }
      });
  }

  // Open the update modal with pre-filled data
  function openUpdateModal(id, name) {
      $('#updateCategoryId').val(id);
      $('#updateCategoryName').val(name);
      $('#updateCategoryModal').modal('show');
  }

  // Handle update category form submission
  $('#updateCategoryForm').submit(function(event) {
      event.preventDefault();
      
      var id = $('#updateCategoryId').val();
      var name = $('#updateCategoryName').val().trim();

      if (name === "") {
          $('#updateMessage').removeClass('alert-success').addClass('alert-danger').text('Please enter a category name.').show();
          return;
      }

      $.ajax({
          url: '../cfc/controllers/categoryController.cfc?method=updateCategory',
          method: 'POST',
          data: {
              id: id,
              name: name
          },
          success: function(response) {
              var result = JSON.parse(response);
              if (result.success) {
                  $('#updateMessage').removeClass('alert-danger').addClass('alert-success').text('Category updated successfully!').show();
                  setTimeout(function() {
                      $('#updateCategoryModal').modal('hide');
                      $('#updateMessage').hide();
                  }, 1000);
                  loadCategories();
              } else {
                  $('#updateMessage').removeClass('alert-success').addClass('alert-danger').text(result.message).show();
                  setTimeout(function() {
                      $('#updateMessage').hide();
                  }, 2000);
              }
          },
          error: function() {
              $('#updateMessage').removeClass('alert-success').addClass('alert-danger').text("An error occurred, please try again later.").show();
          }
      });
  });

  // Attach functions to the window object for external access
  window.openUpdateModal = openUpdateModal;
  window.deleteCategory = deleteCategory;

  // Initial load of categories
  loadCategories();

  // Handle add category form submission
  $('#submitAddCategory').click(function(event) {
      event.preventDefault();
      
      var isValid = true;

      var type = $('#floatingType').val();
      var category = $('#floatingCategory').val().trim();

      // Validation
      if (!type || type === "") {
          $('#message').removeClass('alert-success').addClass('alert-danger').text('Please select a type.').show();
          isValid = false;
      }

      if (!category || category === "") {
          $('#message').removeClass('alert-success').addClass('alert-danger').text('Please enter a category name.').show();
          isValid = false;
      }

      if (isValid) {
          $.ajax({
              url: '../cfc/controllers/categoryController.cfc?method=addCategory',
              method: 'POST',
              data: {
                  type: type,
                  category: category
              },
              success: function(response) {
                  var result = JSON.parse(response);
                  if (result.success) {
                      $('#message').removeClass('alert-danger').addClass('alert-success').text('Category added successfully!').show();
                      setTimeout(function() {
                          $('#verticalycentered1').modal('hide');
                          $('#message').hide();
                          $('#floatingCategory').val('');
                      }, 1000);
                      loadCategories();
                  } else {
                      $('#message').removeClass('alert-success').addClass('alert-danger').text(result.message).show();
                      setTimeout(function() {
                          $('#message').hide();
                      }, 2000);
                  }
              },
              error: function() {
                  $('#message').removeClass('alert-success').addClass('alert-danger').text('An error occurred while adding the category.').show();
              }
          });
      }
  });

  let categoryToDelete = null;

  // Function to delete a category
  function deleteCategory(categoryID) {
      categoryToDelete = categoryID;
      $('#deleteCategory').modal('show');
  }

  // Confirm and delete category
  $('#confirmDelete').click(function() {
      if (categoryToDelete !== null) {
          $.ajax({
              url: '../cfc/controllers/categoryController.cfc?method=deleteCategoryWithAssociations',
              type: 'POST',
              data: { categoryID: categoryToDelete },
              success: function(response) {
                  var result = JSON.parse(response);
                  if (result.success) {
                      $('#deleteMessage').removeClass('alert-danger').addClass('alert-success').text(result.message).show();
                      setTimeout(function() {
                          $('#deleteCategory').modal('hide');
                          $('#deleteMessage').hide();
                      }, 2000);
                      loadCategories();
                  } else {
                      $('#deleteMessage').removeClass('alert-success').addClass('alert-danger').text(result.message).show();
                      setTimeout(function() {
                          $('#deleteMessage').hide();
                      }, 2000);
                  }
              },
              error: function() {
                  $('#deleteMessage').removeClass('alert-success').addClass('alert-danger').text('An error occurred while deleting the category.').show();
                  setTimeout(function() {
                      $('#deleteMessage').hide();
                  }, 2000);
              }
          });
      }
  });
});
