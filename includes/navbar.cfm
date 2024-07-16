<cfset currentPage = GetFileFromPath(cgi.SCRIPT_NAME)>
<cfoutput>
<aside id="sidebar" class="sidebar">
    <ul class="sidebar-nav" id="sidebar-nav">
        <li class="nav-item">
            <cfif currentPage eq "index.cfm">
                <a class="nav-link" href="#application.baseAppURLPath#">
            <cfelse>
                <a class="nav-link collapsed" href="#application.baseAppURLPath#">
            </cfif>
                <i class="bi bi-grid"></i>
                <span>Dashboard</span>
            </a>
        </li><!-- End Dashboard Nav -->

        <li class="nav-item">
            <cfif currentPage eq "transactionList.cfm">
                <a class="nav-link" href="#application.baseAppURLPath#views/transactionList.cfm">
            <cfelse>
                <a class="nav-link collapsed" href="#application.baseAppURLPath#views/transactionList.cfm">
            </cfif>
                <i class="bi bi-card-list"></i>
                <span>All Transactions</span>
            </a>
        </li><!-- End All Transactions Nav -->

        <li class="nav-item">
            <cfif currentPage eq "charts.cfm">
                <a class="nav-link" href="#application.baseAppURLPath#views/charts.cfm">
            <cfelse>
                <a class="nav-link collapsed" href="#application.baseAppURLPath#views/charts.cfm">
            </cfif>
                <i class="bi bi-bar-chart"></i>
                <span>Charts and Graphs</span>
            </a>
        </li><!-- End Charts and Graphs Nav -->

        <li class="nav-item">
            <cfif currentPage eq "reports.cfm">
                <a class="nav-link" href="#application.baseAppURLPath#views/reports.cfm">
            <cfelse>
                <a class="nav-link collapsed" href="#application.baseAppURLPath#views/reports.cfm">
            </cfif>
                <i class="bi bi-file-earmark"></i>
                <span>Reports</span>
            </a>
        </li><!-- End Reports Nav -->

        <li class="nav-item">
            <cfif currentPage eq "manageReciept.cfm">
                <a class="nav-link" href="#application.baseAppURLPath#views/manageReciept.cfm">
            <cfelse>
                <a class="nav-link collapsed" href="#application.baseAppURLPath#views/manageReciept.cfm">
            </cfif>
                <i class="bi bi-receipt"></i>
                <span>Manage Receipts</span>
            </a>
        </li><!-- End Manage Receipts Nav -->

        <li class="nav-item">
            <cfif currentPage eq "manageCategory.cfm">
                <a class="nav-link" href="#application.baseAppURLPath#views/manageCategory.cfm">
            <cfelse>
                <a class="nav-link collapsed" href="#application.baseAppURLPath#views/manageCategory.cfm">
            </cfif>
                <i class="bi bi-gear"></i>
                <span>Manage Categories</span>
            </a>
        </li><!-- End Manage Categories Nav -->

        <li class="nav-item">
            <cfif currentPage eq "userSetting.cfm">
                <a class="nav-link" href="#application.baseAppURLPath#views/userSetting.cfm">
            <cfelse>
                <a class="nav-link collapsed" href="#application.baseAppURLPath#views/userSetting.cfm">
            </cfif>
                <i class="bi bi-gear"></i>
                <span>User Settings</span>
            </a>
        </li><!-- End User Settings Nav -->
    </ul>
</aside><!-- End Sidebar -->
</cfoutput>
