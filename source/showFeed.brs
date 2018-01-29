'**********************************************************
'**  Video Player Example Application - Show Feed 
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

'******************************************************
'** Set up the show feed connection object
'** This feed provides the detailed list of shows for
'** each subcategory (categoryLeaf) in the category
'** category feed. Given a category leaf node for the
'** desired show list, we'll hit the url and get the
'** results.     
'******************************************************

Function InitShowFeedConnection(category As Object) As Object

    if validateParam(category, "roAssociativeArray", "initShowFeedConnection") = false return invalid 

    conn = CreateObject("roAssociativeArray")
    conn.UrlShowFeed  = category.feed 

    conn.Timer = CreateObject("roTimespan")

    conn.LoadShowFeed    = load_show_feed
    conn.ParseShowFeed   = parse_show_feed
    conn.InitFeedItem    = init_show_feed_item

    print "created feed connection for " + conn.UrlShowFeed
    return conn

End Function


'******************************************************
'Initialize a new feed object
'******************************************************
Function newShowFeed() As Object

    o = CreateObject("roArray", 100, true)
    return o

End Function


'***********************************************************
' Initialize a ShowFeedItem. This sets the default values
' for everything.  The data in the actual feed is sometimes
' sparse, so these will be the default values unless they
' are overridden while parsing the actual game data
'***********************************************************
Function init_show_feed_item() As Object
    o = CreateObject("roAssociativeArray")

    o.ContentId        = ""
    o.Title            = ""
    o.ContentType      = ""
    o.ContentQuality   = ""
    o.Synopsis         = ""
    o.Genre            = ""
    o.Runtime          = ""
    o.videoRendition   = ""
    o.videoURL         = ""
    o.videoID          = ""
    o.ReleaseDate      = ""
    o.Director         = ""
    o.StreamQualities  = CreateObject("roArray", 5, true) 
    o.StreamBitrates   = CreateObject("roArray", 5, true)
    o.StreamUrls       = CreateObject("roArray", 5, true)

    return o
End Function


'*************************************************************
'** Grab and load a show detail feed. The url we are fetching 
'** is specified as part of the category provided during 
'** initialization. This feed provides a list of all shows
'** with details for the given category feed.
'*********************************************************
Function load_show_feed(conn As Object, categoryTitle as String) As Dynamic
    print ("load_show_feed")
    if validateParam(conn, "roAssociativeArray", "load_show_feed") = false return invalid 

    print "url: " + conn.UrlShowFeed 
    response = aSyncFetch2(conn.UrlShowFeed, false, "", 0, true)
    
    if response = "reauthenticate" then
        reauthenticate()
        response = aSyncFetch2(conn.UrlShowFeed, false, "", 0, false)
        if response = "reauthenticate" then
            ShowErrorDialog("Please visit http://exploitation.tv in your browser to sign up for full access to our films.", "Could not authenticate again")
            m.RegToken = invalid
            RegDelete("RegToken", "Authentication")
        endif
    else if response = "failed" then
        return false
    endif
    
    'print "response"
    'print response
    feed = newShowFeed()
    m.feed = feed
    xml=CreateObject("roXMLElement")
    if not xml.Parse(response) then
        print "Error Parsing feed"
        return feed
    endif
    
    'http = NewHttp(conn.UrlShowFeed)

    m.Timer.Mark()
    'rsp = http.GetToStringWithRetry()
    print "Request Time: " + itostr(m.Timer.TotalMilliseconds())

    if xml.GetName() <> "result" then
        print "no result tag found"
        return feed
    endif

    if islist(xml.GetBody()) = false then
        print "no feed body found"
        ShowErrorDialog("Please visit http://exploitation.tv in your browser to create a watchlist", "Could not find a watchlist")
                    
        return feed
    endif

    m.Timer.Mark()
    m.ParseShowFeed(xml, feed, categoryTitle)
    print "Show Feed Parse Took : " + itostr(m.Timer.TotalMilliseconds())

    return feed

End Function


 

'**************************************************************************
'**************************************************************************
Function parse_show_feed(xml As Object, feed As Object, categoryTitle as String) As Void
    print "parse_show_feed"
    showCount = 0
    showList = xml.GetChildElements()
    'PrintXML(xml, 1) 

    for each curShow in showList

        'for now, don't process meta info about the feed size
        if curShow.GetName() = "resultLength" or curShow.GetName() = "endIndex" then
            goto skipitem
        endif

        item = init_show_feed_item()
        
        
        'rex = CreateObject("roRegex", "<img[^>]+src=([a-z]+)", "i")
        'print "curShow"
        
        thumbnailTag = curShow.thumbnail.GetText()
        'print "blah: "
        'print thumbnailTag
        thumbURL = " "
        if (thumbnailTag <> "") then
            thumbList = CreateObject("roList")
            r1 = CreateObject("roRegex", " +", "") ' split on one or more slashes
            thumbList = r1.Split(thumbnailTag)
            thumbURL = thumbList[1]
            'print thumbURL
            thumbURL = thumbURL.Replace("src=", "") 
            jpgLength = Len(thumbURL) 
            thumbURL =  mid(thumbURL, 2, jpgLength-2)
        endif
       ' print "thumbnailTag: " + thumbnailTag
        'print "thumbURL: " + thumbURL
        
        assetTag = curShow.brightcove_video_asset.GetText()
        
        valueTagsList = CreateObject("roList")
        v1 = CreateObject("roRegex", "value=+", "")
        'print "assetTag"
        'print assetTag
        valueTagsList = v1.Split(assetTag)
        'print "valueTagsList: " 
        'print valueTagsList
        assetValueURL =  mid(valueTagsList[8], 2, 13)
        'print "assetValueURL"
        'print assetValueURL
        
        
        
        ratingTag = curShow.rating.GetText()
        ratingVariable = CreateObject("roRegex", "/", "") ' split on one or more slashes
        ratingList = ratingVariable.Split(ratingTag)
        
        ratingValue = Str(ratingList[0].toint() / 5 * 100).trim()
        'ratingStr = ratingValue.tostr()
        'print "ratingValue: " + ratingValue
        
        durationTag = curShow.nid.GetText()
        durationVariable = CreateObject("roRegex", " ", "")
        durationList = durationVariable.Split(durationTag)
        durationValue = Str(durationList[0].toint() * 60).trim()
        'print "durationValue: " + durationValue
        
        contentId = assetValueURL.trim()
        'print "contentId"
        'print contentId
        'print "Full asset: " + curShow.brightcove_video_asset.GetText()
        'print "Value: " + assetValueURL
        'fetch all values from the xml for the current show
        item.hdImg            = thumbURL 'validstr(curShow.file_managed_field_data_field_screenshot_uri.GetText()) 
        item.sdImg            = thumbURL 'validstr(curShow.file_managed_field_data_field_screenshot_uri.GetText()) 
        item.ContentId        = contentId 'validstr(curShow.contentId.GetText()) 
        item.Title            = validstr(curShow.node_title.GetText()) 
        item.Title = item.Title.Replace("&#39;", "'")
        item.Title = item.Title.Replace("&#039;", "'")
        item.Title = item.Title.Replace("&quot;", "'")
        item.Title = item.Title.Replace("&amp;", "&")
        item.Description      = validstr(curShow.short_synopsis.GetText()) 
        item.ReleaseDate = validstr(curShow.released.GetText())  
        print "Released: " + validstr(curShow.released.GetText())  
        print "Director: " + validstr(curShow.directors.GetText())   
        item.Director = validstr(curShow.directors.GetText())  
        
        
        item.Director = item.Director.Replace("&#39;", "'")
        item.Director = item.Director.Replace("&#039;", "'") 
        item.Description = item.Description.Replace("&#39;", "'")
        item.Description = item.Description.Replace("&#039;", "'")
        item.Description = item.Description.Replace("&quot;", "'")
        item.Description = item.Description.Replace("&amp;", "&")
        'print "Description: " + validstr(curShow.short_synopsis.GetText())
        'print "Synopsis: " + validstr(curShow.body.GetText())
        item.ContentType      = "Talk" 'validstr(curShow.contentType.GetText())
        item.ContentQuality   = "mp4" 'validstr(curShow.contentQuality.GetText())
        'print "validstr(curShow.body.GetText()):"
        'print validstr(curShow.body.GetText())
        item.Synopsis = validstr(curShow.short_synopsis.GetText())  'validstr(curShow.body.GetText())
        item.Synopsis = item.Synopsis.Replace("&#39;", "'")
        item.Synopsis = item.Synopsis.Replace("&#039;", "'")
        item.Synopsis = item.Synopsis.Replace("&quot;", "'")
        item.Synopsis = item.Synopsis.Replace("&amp;", "&")
        item.Genre            = categoryTitle
        item.Runtime          = durationValue '"1172" 'validstr(curShow.nid.GetText())
        item.videoID = assetValueURL
        'print "assetValueURL: " + assetValueURL
        item.videoRendition   = assetValueURL '"" ' GetRenditionsForVideo(assetValueURL) 
        item.HDBifUrl         = validstr(item.videoURL)
        item.SDBifUrl         = validstr(item.videoURL)
        item.StreamFormat = "mp4" 'validstr(curShow.streamFormat.GetText())
        if item.StreamFormat = "" then  'set default streamFormat to mp4 if doesn't exist in xml
            item.StreamFormat = "mp4"
        endif
        
        'map xml attributes into screen specific variables
        item.ShortDescriptionLine1 = item.Title 
        item.ShortDescriptionLine2 = item.Description
        item.HDPosterUrl           = item.hdImg
        item.SDPosterUrl           = item.sdImg
        
        'print "item.hdImg: " + item.hdImg
        'print "item.sdImg: " + item.sdImg
        'item.HDPosterUrl            = "http://sandbox.exploitation.svod.co/sites/default/files/features-TAPESTRY_OF_PASSION-TAPESTRY_OF_PASSION-001.jpg"
        'item.SDPosterUrl            = "http://sandbox.exploitation.svod.co/sites/default/files/features-TAPESTRY_OF_PASSION-TAPESTRY_OF_PASSION-001.jpg"

        item.Length = strtoi(item.Runtime)
        item.Categories = CreateObject("roArray", 5, true)
        item.Categories.Push(item.Genre)
        item.Actors = CreateObject("roArray", 5, true)
        item.Actors.Push(item.Genre)
        item.Description = item.Synopsis
        item.videoURL = item.videoRendition '.url
        'Set Default screen values for items not in feed
        item.HDBranded = false
        item.IsHD = false
        item.UserStarRating = ratingValue
        item.ContentType = "episode" 

        
        item.StreamBitrates.Push("0")
        item.StreamQualities.Push("HD")
        'print ("Rendition URL: " + item.videoRendition.url)
        'item.StreamUrls.Push(item.videoRendition.url)
        '    endif
        'next idx
        
        showCount = showCount + 1
        feed.Push(item)

        skipitem:

    next

End Function
