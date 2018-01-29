'********************************************************************
'**  Video Player Example Application - Main
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'********************************************************************

Sub Main()

    initTheme()
    
    'Analytics
    'UA_Init("UA-66580511-3")
    globals = getGlobalAA()
    
    globals.analytics = Analytics()
    globals.analytics.startup()
    

    globals.analytics.trackEvent("App", "Launch", "", "", [])
    
    screen=preShowHomeScreen("", "")
    if screen=invalid then
        print "unexpected error in preShowHomeScreen"
        return
    end if

    'showLoginScreen(screen)
    'set to go, time to get started
    
     m.RegToken = RegRead("RegToken", "Authentication")
     RegTokenTime = RegRead("RegTokenTime", "Date")
     
     print "RegTokenTime"
     print RegTokenTime
    
     
     if RegTokenTime <> invalid then
         currentTimeObj = CreateObject("roDateTime")
         dateObj = CreateObject("roDateTime")
         dateObj.fromISO8601String(RegTokenTime)
         m.RegTokenTime = CreateObject("roDateTime")
         m.RegTokenTime = dateObj
         loginHour= m.RegTokenTime.asSeconds() / 3600
         currentHour = currentTimeObj.asSeconds() / 3600
         
         differenceInHours = currentHour - loginHour
         'm.RegToken = invalid
         
         if m.RegToken <> invalid and differenceInHours < 48 then
            print "Regtoken found"
            print m.RegToken
            'initLogin(screen)
            showHomeScreen(screen)
         else if m.RegToken <> invalid and differenceInHours >= 48 then
            m.usernameEntered = RegRead("username", "Authentication")
            m.passwordEntered = RegRead("password", "Authentication")
            authenticate(screen)
           'initLogin(screen)  
         else
            print "RegToken not found"
            print m.RegToken
            initLogin(screen)
         endif
    else 
        print "m.RegTokenTime not found"
        print m.RegTokenTime
        initLogin(screen) 
    endif
    
    globals.analytics.shutdown()
End Sub




Sub initLogin(homeScreen)

    globals = getGlobalAA()
    globals.analytics.trackEvent("User Login", "Entered", "", "", [])
    
    screen = CreateObject("roKeyboardScreen")
    port = CreateObject("roMessagePort") 
    screen.SetMessagePort(port)
    screen.SetTitle("")
    
    
    screen.SetText("")
    screen.SetDisplayText("Please enter your username")
    screen.SetMaxLength(128)
    screen.AddButton(1, "Next")
    screen.AddButton(2, "Exit")
    screen.Show() 
    m.usernameEntered = ""
    'UserCredentials = CreateObject("roAssociativeArray")
    
    'UA_trackEvent("Roku","Login","Start","") 
    while true
         msg = wait(0, screen.GetMessagePort()) 
         print "message received"
         if type(msg) = "roKeyboardScreenEvent"
             if msg.isScreenClosed()
                 return 
             else if msg.isButtonPressed() then
                 print "Evt:"; msg.GetMessage ();" idx:"; msg.GetIndex()
                 if msg.GetIndex() = 1
                     m.usernameEntered = screen.GetText()
                     RegWrite("username", m.usernameEntered, "Authentication")
                     'UserCredentials.usernameEntered = usernameEntered
                     print "username: " + m.usernameEntered 
                     showPasswordScreen(homeScreen)
                     'showHomeScreen(homeScreen)
                     return
                 else if msg.GetIndex() = 2 then
                    screen.Close()
                 endif
             endif
         endif
     end while

End Sub

Sub showPasswordScreen(homeScreen)
    screen = CreateObject("roKeyboardScreen")
    port = CreateObject("roMessagePort") 
    screen.SetMessagePort(port)
    screen.SetTitle("")
    screen.SetText("")
    screen.SetDisplayText("Please enter your password")
    screen.SetMaxLength(128)
    screen.AddButton(1, "Submit")
    screen.AddButton(2, "Back")
    screen.Show() 
    m.passwordEntered = ""
    
    while true
         msg = wait(0, screen.GetMessagePort()) 
         print "message received"
         if type(msg) = "roKeyboardScreenEvent"
             if msg.isScreenClosed()
                 return 
             else if msg.isButtonPressed() then
                 print "Evt:"; msg.GetMessage ();" idx:"; msg.GetIndex()
                 if msg.GetIndex() = 1
                     
                     m.passwordEntered = screen.GetText()
                     
                     print "password: " + m.passwordEntered 
                     RegWrite("password", m.passwordEntered, "Authentication")
                     'showPasswordScreen(homeScreen)
                     
                     authenticate(homeScreen)
                     return 
                 else if msg.GetIndex() = 2 then
                    print msg.GetIndex()
                    screen.Close()
                 endif
             endif
         endif
     end while

End Sub

Function authenticate(homeScreen) As Void
    
    
    if m.RegToken = invalid then m.RegToken = ""
    if isLinked() then
        print "device already linked, skipping registration process" 
        'return 0
    endif
    
    'print "username: " + m.usernameEntered
    print "user : " + m.usernameEntered
    print "password : " + m.passwordEntered
   ' print "passwordEntered: " + passwordEntered
    print "authenticate()"
    connAuth = InitAuthenticate()
    
    User = connAuth.Login(connAuth, m.usernameEntered, m.passwordEntered)
    print "User: " 
    print User
    if User <> "" then
        
        loginDate = CreateObject("roDateTime")
        m.loginDate = loginDate.ToISOString()
        'renew.Mark()
        print m.loginDate
        m.RegToken = User
        RegWrite("RegToken", m.RegToken, "Authentication")
        RegWrite("RegTokenTime", m.loginDate, "Date")
        
        globals = getGlobalAA()
        globals.analytics.trackEvent("User Login", "Successful", "", "", [])
        'UA_trackEvent("Roku","Login","Successful","") 
        showHomeScreen(homeScreen)
    else
        print "Login was invalid"
        'UA_trackEvent("Roku","Login","Failed","") 
        globals = getGlobalAA()
        globals.analytics.trackEvent("User Login", "Failed", "", "", [])
        initLogin(homeScreen)
    endif

    'm.Categories = conn.LoadCategoryFeed(conn)
    'm.Categories = conn.LoadActionFeed(conn)
    'm.CategoryNames = conn.GetCategoryNames()

End Function

Function reauthenticate() As Void
    
    m.usernameEntered = RegRead("username", "Authentication")
    m.passwordEntered = RegRead("password", "Authentication")
    if m.RegToken = invalid then m.RegToken = ""
    if isLinked() then
        print "device already linked, skipping registration process" 
        'return 0
    endif
    
    'print "username: " + m.usernameEntered
    print "user : " + m.usernameEntered
    print "password : " + m.passwordEntered
   ' print "passwordEntered: " + passwordEntered
    print "authenticate()"
    connAuth = InitAuthenticate()
    
    User = connAuth.Login(connAuth, m.usernameEntered, m.passwordEntered)
    print "User: " 
    print User
    if User <> "" then
        
        loginDate = CreateObject("roDateTime")
        m.loginDate = loginDate.ToISOString()
        'renew.Mark()
        print m.loginDate
        m.RegToken = User
        RegWrite("RegToken", m.RegToken, "Authentication")
        RegWrite("RegTokenTime", m.loginDate, "Date")
        
        'globals = getGlobalAA()
        'globals.analytics.trackEvent("User Login", "Successful", "", "", [])
        'UA_trackEvent("Roku","Login","Successful","") 
        'showHomeScreen(homeScreen)
    else
        print "Login was invalid"
        'UA_trackEvent("Roku","Login","Failed","") 
        'globals = getGlobalAA()
        'globals.analytics.trackEvent("User Login", "Failed", "", "", [])
        'initLogin(homeScreen)
    endif

    'm.Categories = conn.LoadCategoryFeed(conn)
    'm.Categories = conn.LoadActionFeed(conn)
    'm.CategoryNames = conn.GetCategoryNames()

End Function

Function isLinked() As Dynamic
    if Len(m.RegToken) > 0  then return true
    return false
End Function


'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** Theme attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "31"
    theme.OverhangSliceSD = "pkg:/images/Overhang_Background_SD.png"
    theme.OverhangLogoSD  = "pkg:/images/Overhang_Logo_SD.png"
    
    theme.BackgroundColor = "#1f1f1f"
    theme.BreadcrumbTextRight = "#1f1f1f"
    theme.BreadcrumbTextLeft = "#313030"
    theme.Rating = "#efdc3d"
    theme.StarRating = "#efdc3d"
    'theme.BreadcrumbTextColor = "#313030"
    
    theme.OverhangOffsetHD_X = "125"
    theme.OverhangOffsetHD_Y = "35"
    theme.OverhangSliceHD = "pkg:/images/Overhang_Background_HD.png"
    theme.OverhangLogoHD  = "pkg:/images/Overhang_Logo_HD.png"

    app.SetThemeAttribute("TitleColor", "#000000")
    app.SetThemeAttribute("SubtitleColor", "#000000")
    app.SetTheme(theme)
    
      

End Sub
