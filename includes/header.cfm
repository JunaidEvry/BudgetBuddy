
<header id="header" class="header fixed-top d-flex align-items-center">
  <i class="bi bi-list toggle-sidebar-btn"></i>
  <div class="d-flex align-items-center justify-content-between">
      <cfoutput>
      <a href="#application.baseAppURLPath#index.cfm" class="logo d-flex align-items-center ms-3">
      <img src="#application.baseAppURLPath#assets/img/logo.png" alt="">
      </cfoutput>
      <span class="d-none d-lg-block">BudgetBuddy</span>
    </a>
  </div><!-- End Logo -->

  <nav class="header-nav ms-auto">
    <ul class="d-flex align-items-center">

      <li class="nav-item dropdown pe-3">
        <a class="nav-link nav-profile d-flex align-items-center pe-0" href="#" data-bs-toggle="dropdown">
        <span class="d-none d-md-block dropdown-toggle ps-2" id="userName"></span>
        </a><!-- End Profile Image Icon -->

        <ul class="dropdown-menu dropdown-menu-end dropdown-menu-arrow profile">
          <li class="dropdown-header">
            <h6 id="profileUserName"></h6>
          </li>
          <li>
            <hr class="dropdown-divider">
          </li>

          <li>
            <a id="signOutLink" class="dropdown-item d-flex align-items-center" href="#">
              <i class="bi bi-box-arrow-right"></i>
              <span>Sign Out</span>
            </a>
          </li>

        </ul><!-- End Profile Dropdown Items -->
      </li><!-- End Profile Nav -->

    </ul>
  </nav><!-- End Icons Navigation -->

</header><!-- End Header -->


    <script>
      $(document).ready(function() {
        $('#signOutLink').on('click', function() {
    
          // Clear local storage
          localStorage.clear();
    
          // Clear session storage
          sessionStorage.clear();
    
          // Make an AJAX request to sign out on the server side
          $.ajax({
            url: '<cfoutput>#application.baseAppURLPath#</cfoutput>cfc/controllers/UserController.cfc?method=signOut',
            type: 'POST',
            success: function(response) {
              var result = JSON.parse(response);
              // Redirect to login page or show a sign-out confirmation message
              if (result.success) {
                window.location.href = '<cfoutput>#application.baseAppURLPath#</cfoutput>views/login.cfm';
              } else {
                console.log(result.message);
              }
            },
            error: function(xhr, status, error) {
              console.error('Sign out failed:', error);
              alert('Failed to sign out. Please try again later.');
            }
          });
        });
        $.ajax({
            url: '<cfoutput>#application.baseAppURLPath#</cfoutput>cfc/controllers/UserController.cfc?method=getUserName',
            method: 'GET',
            success: function(response) {
                var result = JSON.parse(response);
                if (result.success) {
                    $('#userName').text(result.userName);
                    $('#profileUserName').text(result.userName);
                } else {
                    console.error('Error fetching username:', result.message);
                }
            },
            error: function(xhr, status, error) {
                console.error('Error fetching username:', error);
            }
        });
      });
    </script>

    