'**********************************************************
'**  Video Player Example Application - Video Playback 
'**  November 2009
'**  Copyright (c) 2009 Roku Inc. All Rights Reserved.
'**********************************************************

'***********************************************************
'** Create and show the video screen.  The video screen is
'** a special full screen video playback component.  It 
'** handles most of the keypresses automatically and our
'** job is primarily to make sure it has the correct data 
'** at startup. We will receive event back on progress and
'** error conditions so it's important to monitor these to
'** understand what's going on, especially in the case of errors
'***********************************************************  
Function showVideoScreen(episode As Object)
    
    if type(episode) <> "roAssociativeArray" then
        print "invalid data passed to showVideoScreen"
        return -1
    endif

    port = CreateObject("roMessagePort")
    screen = CreateObject("roVideoScreen")
    
    screen.SetMessagePort(port)
    'print "episode.videoID: " + episode.videoID
    videoURL = GetRenditionsForVideo(episode.videoID)
    print videoURL
    
    'H264 
    episode.StreamBitrates = [0]
    episode.StreamUrls = CreateObject("roArray", 5, true)
    episode.StreamUrls.Push(videoURL.url)
    episode.StreamQualities = ["HD"]
    
    
    'HLS
    'episode.StreamBitrates = [0]
    'episode.StreamUrls = [videoUrl]
    'episode.StreamQualities = ["HD"]
    'episode.StreamFormat = "hls"
    'print "episode.Director: " + episode.Director
    
        
    'episode.StreamBitrates = 3.5
    'episode.StreamUrls = CreateObject("roArray", 15, true)
    'episode.StreamUrls.Push(videoURL.url)
    
    'episode.StreamFormat = "hls"
    'print "Video URL under appVideoScreen: " + videoURL.url
    screen.Show()
    screen.SetPositionNotificationPeriod(30)
    'print episode
    screen.SetContent(episode)
    screen.Show()

    'Uncomment his line to dump the contents of the episode to be played
    'PrintAA(episode)

    while true 
        msg = wait(0, port)

        if type(msg) = "roVideoScreenEvent" then
            print "showHomeScreen | msg = "; msg.getMessage() " | index = "; msg.GetIndex()
            if msg.isScreenClosed()
                'UA_trackEvent("Roku Video ","Video playback stop","","") 
                
                globals = getGlobalAA()
                globals.analytics.trackEvent("Video playback", "Stopped", "", "", [])
                print "Screen closed"
                exit while
            else if msg.isRequestFailed()
                print "Video request failure: "; msg.GetIndex(); " " msg.GetData() 
            else if msg.isStatusMessage()
                print "Video status: "; msg.GetIndex(); " " msg.GetData() 
            else if msg.isButtonPressed()
               ' UA_trackEvent("Roku","Video playback stop","","") 
                globals = getGlobalAA()
                globals.analytics.trackEvent("Video playback", "Stopped", "", "", [])
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
            else if msg.isPlaybackPosition() then
                print "Recording Playback Position"
                nowpos = msg.GetIndex()
                'print "episode.ContentId"
                'print episode.ContentId
                RegWrite(episode.ContentId, nowpos.toStr(), "ResumeFrom")
            else
                print "Unexpected event type: "; msg.GetType()
            end if
        else
            print "Unexpected message class: "; type(msg)
        end if
    end while

End Function

