<cfif session.loggedin==false>
    <cflocation url="#application.baseAppURLPath#views/login.cfm" addtoken="false"/>
</cfif>