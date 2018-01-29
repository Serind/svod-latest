'Function GetRenditionsForVideo(videoID as String)
'' grabbing all the data for the playlist at once can result in a huge chunk of JSON and processing that into a BS structure can crash the box
'  'rendURL = "http://api.brightcove.com/services/library?command=find_video_by_id&media_delivery=http&video_fields=renditions&video_id=" + video.id + "&token=" + Config().brightcoveToken
'  rendURL = "http://api.brightcove.com/services/library?command=find_video_by_id&media_delivery=http&video_fields=renditions&video_id=" + videoID + "&token=" + Config().brightcoveToken
'   print "Rendition URL: "; rendURL
'  raw = GetStringFromURL(rendURL)
'  json = SimpleJSONParser(raw)
'  'PrintAA(json)
'
'  if json = invalid then
'    return
'  end if
'
'  for each rendition in json.renditions
'    ' FIXME: allow HLS streams here?  They all may just work, but this still needs to be
'    ' tried out.  RTMP streams would still need to be excluded.
'    if UCase(ValidStr(rendition.videocontainer)) = "MP4" and UCase(ValidStr(rendition.videocodec)) = "H264"
'
'      newStream = {
'        url:  ValidStr(rendition.url)
'        bitrate: Int(StrToI(ValidStr(rendition.encodingrate)) / 1000)
'      }
'
'      if StrToI(ValidStr(rendition.frameheight)) > 720
'        video.fullHD = true
'      end if
'      if StrToI(ValidStr(rendition.frameheight)) > 480
'        video.isHD = true
'        video.hdBranded = true
'        newStream.quality = true
'      end if
'
'      video.streams.Push(newStream)
'    end if
'  next
'  
'  return video
'end Function

Function GetRenditionsForVideo(videoID as String)
    
  ' grabbing all the data for the playlist at once can result in a huge chunk of JSON and processing that into a BS structure can crash the box
  'rendURL = "http://api.brightcove.com/services/library?command=find_video_by_id&media_delivery=http_ios&video_fields=name,length,FLVURL&video_id=" + videoID + "&token=" + Config().brightcoveToken
  rendURL = "http://api.brightcove.com/services/library?command=find_video_by_id&media_delivery=http&video_fields=renditions&video_id=" + videoID + "&token=" + Config().brightcoveToken
  
  'print "Rendition URL: "; rendURL
  raw = GetStringFromURL(rendURL)
  json = SimpleJSONParser(raw)
  PrintAA(json)
  videoURL = ""
  if json = invalid then
    print "invalid json"
    return videoURL
  end if

  'print "json: "
  'print "json.FLVURL: " + json.FLVURL
  'return json.FLVURL
 
'  H264 
  highestBitrate = 0
  for each rendition in json.renditions
'     FIXME: allow HLS streams here?  They all may just work, but this still needs to be
'     tried out.  RTMP streams would still need to be excluded.
'    print "test: "
    print "First URL: " + rendition.url
    if (highestBitrate < Int(StrToI(ValidStr(rendition.encodingrate)) / 1000)) then
        highestBitrate = Int(StrToI(ValidStr(rendition.encodingrate)) / 1000)
    end if
  next
'   
  print "highestBitrate: "
  print highestBitrate
  for each rendition in json.renditions    
    if UCase(ValidStr(rendition.videocontainer)) = "MP4" and UCase(ValidStr(rendition.videocodec)) = "H264"
        videoURL = ValidStr(rendition.url)
        print "Video URL: " + videoURL
      if (highestBitrate = Int(StrToI(ValidStr(rendition.encodingrate)) / 1000)) then 
         'bitrate 
          newStream = {
            url:  ValidStr(rendition.url)
            bitrate: Int(StrToI(ValidStr(rendition.encodingrate)) / 1000)
           }
          print "bitrate:"
          print newStream.bitrate
      end if
    end if
  next
'  
  return newStream
end Function