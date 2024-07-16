component accessors="true" {    
    // Application settings
    this.name = "FinanceManager";
    this.applicationTimeout = createTimeSpan(0, 12, 0, 0); // 12 hours
    this.sessionManagement = true;
    this.sessionTimeout = createTimeSpan(0, 2, 0, 0); // 2 hours
    this.setClientCookies = true;
    this.datasource = "FinanceManager";
    
    // Default settings
    this.defaultSettings = {
        theme: "dark",
        timeZone: "Asia/Culcutta",
        language: "en",
        dateFormat: "mm/dd/yyyy",
        currency: "INR"
    };

    // Function to initialize application
    function onApplicationStart() {
        application.settings = this.defaultSettings;
        application.baseAppURLPath = "http://#cgi.server_name#:#cgi.server_port##Replace(cgi.script_name,ListLast(cgi.script_name, "/"),"")#";
        return true;
    }

    // Function to initialize session
    function onSessionStart() {
        session.loggedIn = false;
    }

    function onRequestStart(string targetPage) {
        // application.baseAppURLPath = "http://#cgi.server_name#:#cgi.server_port##Replace(cgi.script_name,ListLast(cgi.script_name, "/"),"")#";
        // request.basePath = "#Replace(cgi.script_name,ListLast(cgi.script_name, "/"),"")#";
        if(session.loggedIn){
            var userSettingsDao = new cfc.models.userSettingsDao();
            var settingsResult = userSettingsDao.getUserSettingsByUserID(session.userID);
            } 
    }

    



}
