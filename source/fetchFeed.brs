


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

function aSyncFetch2(url as String, writeToFile = false, fileName = "tmp:/aSyncResponseTemp.txt", timeout = 0, trace = false, addVars = "") as String
    
'   *** Define necessary variables ***
    if trace then print "Trace:  Entering aSyncFetch"
    if trace then print "Trace:  URL: " + url + ", Timeout: " + timeout.toStr()
 
    print "m.RegToken: " + m.RegToken
    response = createObject("roString")
    urlT = createObject("roURLtransfer")
    
    JSONArray = createObject("roAssociativeArray")
    
    if type(addVars) = "roAssociativeArray" then
        for each n in addVars
            JSONArray[n] = addVars[n]
        end for
    endif

    if trace then print "JSONArray: " 
    if trace then print JSONArray
'   *** Set URLTransfer Variables ***
    
    'configVariables = LoginCookie.session_name + "=" + LoginCookie.sessid
    'print "Config headers: " + configVariables
    
 
    urlT.addHeader("Cookie", m.RegToken) ' Config().session_name + "=" + Config().sessid)  '"SESS194fe7cf52e75dbe09e404a4095e542b=GOoe5k8p6txL4UZPx_9evJZeUy4PfiAbZM1vBNwKEJ4")
    urlT.setUrl(url)
    urlT.enableCookies()
    urlT.setPort(createObject("roMessagePort"))
    
'   *** Perform the fetch. ***simpleJSONBuilder
    waiting = ShowPleaseWait("Loading...", "")
    if trace then print "Trace:  Beginning Fetch"
    
    
    num_retries%     = 5
    str = ""
    json = rdSerialize(JSONArray, "JSON")
    print json
    while num_retries% > 0
        if (urlT.AsyncGetToString())
            event = wait(timeout, urlT.GetPort())
            if type(event) = "roUrlEvent"
                respCode = event.GetResponseCode()
                print "respCode: "
                print respCode
                if respCode = 200 then
                    
                    if trace then print "Url Transfer with url " + url + " successful"
                    response = event.GetString()
                    exit while
                else if respCode = 401 then
                    if trace then print "While updating trending shows with url " + url + ", returned 401 error (couldn't authenticate)"
                    print "401"
                    return "reauthenticate"
                else   
                    if trace then print "While updating login with url " + url + ", returned " + respCode.toStr() + " error (unknown error)"
                    return "failed"
            end if
            else if event = invalid
                urlT.AsyncCancel()
                urlT = CreateObject("roUrlTransfer")
                urlT.SetPort(CreateObject("roMessagePort"))
                urlT.SetUrl(url)
                timeout = 4 * timeout
                if trace then print "retrying with timeout of: " + timeout.toStr()
            else
                if trace then print "roUrlTransfer::AsyncGetToString(): unknown event"
                return "failed" 
            endif
            endif
            num_retries% = num_retries% - 1
        end while
    
    if trace then print "Response from server: "
    
    'if trace then print response
        
    if response = "" then 
        return "failed"
    end if 
    
    'Cookie:BC_BANDWIDTH=1433713401788X9126; 
    'Drupal.tableDrag.showWeight=0; 
    'SESSdc59f6edc2b97979d3c950d462955b51=1f6v6ZCNTy38FUrGtBKbGxdxEHbtRS-EEi21LCX7_78;
    ' __utma=100168010.1319931006.1431555703.1435091045.1436200834.4; 
     '__utmc=100168010; 
     '__utmz=100168010.1431555703.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); 
     'SESS194fe7cf52e75dbe09e404a4095e542b=PE7aQ-lMhqT6ZzjvbuqNEpYqHtsjEHOsc0EPVYok61g; 
     'DrupalAdminToolbar=expanded%3D1%26activeTab%3Dadmin-menu; 
     'DrupalModuleFilter=activeTab%3Dall; __utmt=1; 
     '__utma=102366211.882284502.1433424232.1436721641.1437236581.12; 
     '__utmb=102366211.1.10.1437236581; __utmc=102366211; 
     '__utmz=102366211.1433424232.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); has_js=1
    
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
    
    waiting.Close()
    return response
    
end function



