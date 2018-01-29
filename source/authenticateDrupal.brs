Function InitAuthenticate() As Object

    connAuth = CreateObject("roAssociativeArray")
    loginCookie = CreateObject("roAssociativeArray")
    
    connAuth.sessid = ""
    connAuth.session_name = ""
    
    'connAuth.authenticationURL   = "http://exploitation.tv/roku/api/user/login"
    connAuth.authenticationURL   = "http://exploitation.tv/roku/api/user/login"
    'conn.UrlPrefix = "http://sandbox.exploitation.svod.co/roku/api/views"
    
    connAuth.Timer = CreateObject("roTimespan")

    connAuth.Login    = load_authentication
    
    connAuth.GetSessionId    = get_session_id
    
    print "created authentication connection for " + connAuth.authenticationURL
    return connAuth

End Function

'*****************************************
'   aSyncFetch(url)
'   @params:    url as String to fetch from, 
'               (optional) writeToFile, if true, must supple filename to write to.
'               (optional) fileName, when writing to a file.
'               (optional) timeout as Integer (in miliseconds)
'               (optional) trace, boolean
'               (optional) addVars as roAssociativeArray (variables to be added to the JSON Post.)
'   @return:    response as String
'*****************************************

function aSyncFetch(url as String, writeToFile = false, fileName = "tmp:/aSyncResponseTemp.txt", timeout = 0, trace = false, addVars = "") as String
    
'   *** Define necessary variables ***
    if trace then print "Trace:  Entering aSyncFetch"
    if trace then print "Trace:  URL: " + url + ", Timeout: " + timeout.toStr()
    
    response = createObject("roString")
    urlT = createObject("roURLtransfer")
    cookies = urlT.GetCookies("", "Blah")
    'print cookies.blahName
    for each n in cookies
        print cookies[n]
    end for
    
    JSONArray = createObject("roAssociativeArray")
    
    if type(addVars) = "roAssociativeArray" then
        for each n in addVars
            JSONArray[n] = addVars[n]
        end for
    endif

    if trace then print "JSONArray: " 
    if trace then print JSONArray
'   *** Set URLTransfer Variables ***
    urlT.addHeader("Content-Type", "application/json")
    urlT.setUrl(url)
    urlT.setPort(createObject("roMessagePort"))
    urlT.EnableCookies()
    
'   *** Perform the fetch. ***simpleJSONBuilder
    if trace then print "Trace:  Beginning Fetch"
    
    num_retries%     = 5
    str = ""
    json = rdSerialize(JSONArray, "JSON")
    print json
    while num_retries% > 0
        if (urlT.AsyncPostFromString(json))
            event = wait(timeout, urlT.GetPort())
            if type(event) = "roUrlEvent"
                respCode = event.GetResponseCode()
                if respCode = 200 then
                    if trace then print "Url Transfer with url " + url + " successful"
                    response = event.GetString()
                    exit while
                else if respCode = 401 then
                    if trace then print "While updating trending shows with url " + url + ", returned 401 error (couldn't authenticate)"
                    return "failed"
                else   
                    if trace then print "While updating login with url " + url + ", returned " + respCode.toStr() + " error (unknown error)"
                    return "failed"
            end if
            else if event = invalid
                urlT.AsyncCancel()
                urlT = CreateObject("roUrlTransfer")
                urlT.SetPort(CreateObject("roMessagePort"))
                urlT.SetUrl(url)
                urlT.addHeader("username", username)
                urlT.addHeader("password", password)
                timeout = 4 * timeout
                if trace then print "retrying with timeout of: " + timeout.toStr()
            else
                if trace then print "roUrlTransfer::AsyncPostFromString(): unknown event"
                return "failed" 
            endif
            endif
            num_retries% = num_retries% - 1
        end while
    
    if trace then print "Response from server: "
    
    if trace then print response
    
    if response = "" then return "failed"
    
    '<?xml version="1.0" encoding="utf-8"?>
    '<result>
        '<sessid>mZ4a4bbgW3C0lcspEPI4-4vltGZ3SbqSP7g0PvZzAEQ</sessid>
        '<session_name>SESS194fe7cf52e75dbe09e404a4095e542b</session_name>
        '<user>
            '<uid>1330</uid>
            '<name>a</name>
            '<theme></theme>
            '<signature></signature>
            '<signature_format>2</signature_format>
            '<created>1436721307</created>
            '<access>1436735829</access>
            '<login>1436736030</login>
            '<status>1</status>
            '<timezone/>
            '<language></language>
            '<picture>0</picture>
            '<data><ckeditor_default>t</ckeditor_default><ckeditor_show_toggle>t</ckeditor_show_toggle><ckeditor_width>100%</ckeditor_width><ckeditor_lang>en</ckeditor_lang><ckeditor_auto_lang>t</ckeditor_auto_lang><mimemail_textonly>0</mimemail_textonly></data>
            '<roles is_array="true">
                '<item>authenticated user</item>
                '<item>Premium Member</item>
                '<item>Beta Tester</item>
            '</roles>
            '<field_first_name><und is_array="true">
                '<item><value>Test</value><format/><safe_value>Test</safe_value></item></und>
            '</field_first_name>
            '<field_last_name><und is_array="true"><item><value>Account</value><format/><safe_value>Account</safe_value></item></und></field_last_name>
            '<metatags/>
         '</user>
    '</result>

    return response
    
end function

Function get_session_id(connAuth As Object) As Object
    print "blah: " + connAuth.sessid
    return connAuth.sessid
End Function

'******************************************************************
'** Auth
'******************************************************************
Function load_authentication(connAuth As Object, username As String, password As String) As Dynamic

    http = NewHttp(connAuth.authenticationURL)
    if username.Instr("@") = -1 then
        print "username: " + username
    else
        print "email: " + username
    endif
    
    print "password: " + password
    roUrlTransfer=CreateObject("roUrlTransfer")       
    roUrlTransfer.SetURL(connAuth.authenticationURL)
    
    
    'roUrlTransfer.EnableCookies()
    'req.AddHeader("username","a")
    'req.AddHeader("password","123456")
    
    'req.AddHeader("Accept", "*/*")
    'response = req.GetToString()
    
    'print "response: " + response
    'parameters = {                                    
       'username : "a",
       'password : "123456"
    ' }
    'print parameters.password 
    'json = rdSerialize(parameters, "JSON")
    'print "Posting to " + roUrlTransfer.GetUrl() + ": " + json
    'response = roUrlTransfer.PostFromString(json)
    'xml=CreateObject("roXMLElement")
    'if not xml.Parse(response) then
     '    print "Can't parse response"
       ' return invalid
    'else
    '    print "XML came back"
    'endif
    'print ParseJSON(response)

    response = aSyncFetch(connAuth.authenticationURL, false, "", 0, true,  {
        username : username
        password : password
    })
    
    if response = "failed" then 
        print "Login failed"
        return ""
        
    endif
    
    xml=CreateObject("roXMLElement")
    if not xml.Parse(response) then
        print "Can't parse response"
        return ""
    else
        print "XML came back"
        print "Session ID: " + xml.sessid.GetText()
        print "Session Name: " + xml.session_name.GetText()
        
        
        connAuth.sessid = xml.sessid.GetText()
        connAuth.session_name = xml.session_name.GetText()
        connAuth.token = connAuth.session_name + "=" + connAuth.sessid
        'Config().session_name = xml.session_name.GetText()
        print "sessid: " + connAuth.sessid
        'print "sess name: " + m.LoginCookie.session_name
        'm.AddSessionDetails(LoginCookie)
        
        
    endif

        
    m.Timer.Mark()
   

    return connAuth.token

End Function



