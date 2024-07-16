<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta content="width=device-width, initial-scale=1.0" name="viewport">

    <title>Finance Manager</title>
    <meta content="" name="description">
    <meta content="" name="keywords">
    <cfoutput>

    <!-- Google Fonts -->
    <link href="https://fonts.gstatic.com" rel="preconnect">
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i,700,700i|Nunito:300,300i,400,400i,600,600i,700,700i|Poppins:300,300i,400,400i,500,500i,600,600i,700,700i" rel="stylesheet">

    <!-- Vendor CSS Files -->
    <link href="#application.baseAppURLPath#assets/vendor/bootstrap/css/bootstrap.min.css" rel="stylesheet">
    <link href="#application.baseAppURLPath#assets/vendor/bootstrap-icons/bootstrap-icons.css" rel="stylesheet">
    <link href="#application.baseAppURLPath#assets/vendor/boxicons/css/boxicons.min.css" rel="stylesheet">
    <link href="#application.baseAppURLPath#assets/vendor/quill/quill.snow.css" rel="stylesheet">
    <link href="#application.baseAppURLPath#assets/vendor/quill/quill.bubble.css" rel="stylesheet">
    <link href="#application.baseAppURLPath#assets/vendor/remixicon/remixicon.css" rel="stylesheet">
    <link href="#application.baseAppURLPath#assets/vendor/simple-datatables/style.css" rel="stylesheet">

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/handlebars.js/4.7.7/handlebars.min.js"></script>
    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.11.5/css/jquery.dataTables.css">
    <script type="text/javascript" charset="utf8" src="https://cdn.datatables.net/1.11.5/js/jquery.dataTables.js"></script>

    <!-- Template Main CSS File -->
    <cfif StructKeyExists(session, "userSettings") and StructKeyExists(session.userSettings, "theme") and session.userSettings.theme eq "light">
        <link href="#application.baseAppURLPath#assets/css/style.css" rel="stylesheet">
    <cfelse>
        <link href="#application.baseAppURLPath#assets/css/darkstyle.css" rel="stylesheet">
    </cfif>
    </cfoutput>
</head>

<body>
    <cfinclude template="./includes/checkSession.cfm" runonce="true" />
    <cfinclude template="./includes/header.cfm" runonce="true" />
    <cfinclude template="./includes/navbar.cfm" runonce="true" />

    <main id="main" class="main">
        <div class="themeColour">
            <div id="errorMessage" class="alert alert-danger alert-dismissible fade show" style="display:none;" role="alert">
                <i class="bi bi-exclamation-octagon me-1"></i>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>