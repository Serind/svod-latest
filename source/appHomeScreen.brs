'*****************************************************************
'**  Video Player Example Application -- Home Screen
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'*****************************************************************

'******************************************************
'** Perform any startup/initialization stuff prior to 
'** initially showing the screen.  
'******************************************************
Function preShowHomeScreen(breadA=invalid, breadB=invalid) As Object

    if validateParam(breadA, "roString", "preShowHomeScreen", true) = false return -1
    if validateParam(breadA, "roString", "preShowHomeScreen", true) = false return -1

    port=CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    
    screen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    screen.SetListStyle("flat-category")
    screen.setAdDisplayMode("scale-to-fit")
    return screen

End Function

Function logout(screen As Object) As Void
    RegDelete("RegToken", "Authentication")
    RegDelete("RegTokenTime", "Date") 
    RegDelete("username", "Authentication") 
    RegDelete("password", "Authentication") 
    m.logout = 1
    screen.Close() 
End Function


'******************************************************
'** Display the home screen and wait for events from 
'** the screen. The screen will show retreiving while
'** we fetch and parse the feeds for the game posters
'******************************************************
Function showHomeScreen(screen) As Integer

    
    if validateParam(screen, "roPosterScreen", "showHomeScreen") = false return -1
    print "showHomeScreen"
    initCategoryList()
    screen.SetContentList(m.Categories.Kids)
    screen.SetFocusedListItem(1)
    screen.Show()
    
    

    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            print "showHomeScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListFocused() then
                print "list focused | index = "; msg.GetIndex(); " | category = "; m.curCategory
            else if msg.isListItemSelected() then
                'UA_trackEvent("Roku","Category Clicked","test","1") 
                print "isListItemSelected"
                'print m.curCategory
                print "list item selected | index = "; msg.GetIndex()
                kid = m.Categories.Kids[msg.GetIndex()]
                if kid.type = "special_category" then
                    displaySpecialCategoryScreen()
                else if kid.Title = "Logout" then
                    print "We have a logout situation"
                    logout(screen)
                else
                    if kid.Title <> invalid then
                        globals = getGlobalAA()
                        globals.analytics.trackEvent("Category", "Clicked", kid.Title, "1", [])
                    end if
                    displayCategoryPosterScreen(kid)
                end if
            else if msg.isScreenClosed() then
                return -1
            else 
                print "Possible Logout"
                if m.logout <> invalid then
                    screen.Close()
                end if
            end if
        end If
    end while

    return 0

End Function


'**********************************************************
'** When a poster on the home screen is selected, we call
'** this function passing an associative array with the 
'** data for the selected show.  This data should be 
'** sufficient for the show detail (springboard) to display
'**********************************************************
Function displayCategoryPosterScreen(category As Object) As Dynamic
    print "displayCategoryPosterScreen"
    if validateParam(category, "roAssociativeArray", "displayCategoryPosterScreen") = false return -1
    screen = preShowPosterScreen(category.Title, "")
    showPosterScreen(screen, category)

    return 0
End Function

'**********************************************************
'** Special categories can be used to have categories that
'** don't correspond to the content hierarchy, but are
'** managed from the server by data from the feed.  In these
'** cases we might show a different type of screen other
'** than a poster screen of content. For example, a special
'** category could be search, music, options or similar.
'**********************************************************
Function displaySpecialCategoryScreen() As Dynamic

    ' do nothing, this is intended to just show how
    ' you might add a special category ionto the feed

    return 0
End Function

'************************************************************
'** initialize the category tree.  We fetch a category list
'** from the server, parse it into a hierarchy of nodes and
'** then use this to build the home screen and pass to child
'** screen in the heirarchy. Each node terminates at a list
'** of content for the sub-category describing individual videos
'************************************************************
Function initCategoryList() As Void

    conn = InitCategoryFeedConnection()
    'connHorror = InitHorrorFeedConnection()
    
    
    'm.Horror = connHorror.LoadHorrorFeed(connHorror)
    m.Categories = conn.LoadCategoryFeed(conn)
   ' print "Config headers: " + configVariables
    'm.Categories = conn.LoadActionFeed(conn)
    'm.CategoryNames = conn.GetCategoryNames()

End Function

'************************************************************
'** initialize the category tree.  We fetch a category list
'** from the server, parse it into a hierarchy of nodes and
'** then use this to build the home screen and pass to child
'** screen in the heirarchy. Each node terminates at a list
'** of content for the sub-category describing individual videos
'************************************************************
Function initVideoURL() As Void
    'configUrl = "http://api.brightcove.com/services/library?command=find_playlists_for_player_id&player_id=" + Config().playerID +"&playlist_fields=id,name,thumbnailURL&token=" + Config().brightcoveToken
   

End Function
