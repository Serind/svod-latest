''
'' Used to manage account settings and theme
''

Function Config() As Object
  this = {
    ' the name to show on top of screens
    appName: "SVOD"
    ' whether to use the Smart Player or Brightcove player settings below
    useSmartPlayer: false,
    ' whether to show the playlist screen, even if there is only one playlist
    alwaysShowPlaylists: true
    
    'http: http_ios

    '' Smart Player setup: this block of config is needed when using a Smart Player.
    ' the media API token, which MUST be a Brightcove read token with URL access
    
    ' brightcoveToken: "1haf2aFRHkf2j4_cfBV3O0EOYDKs-0K1M-nqUT6qM1JY4zNaAvab4w.."
    brightcoveToken: "hOVLg7xzpIuBbTeMwDRKZCv75Mu1OPIWjj6ggwQzxasdC03a77npWQ.."
    
    ' the smart player is used for its attached playlists
    playerID: "4207755097001"
    
    loggedIn: false
    '' Brightcove Player setup: this block of config is needed when using a Brightcove
    '' Player, the latest player system
    playerURL: "http://players.brightcove.net/2549849259001/0e39f135-a34c-490d-8a3f-631e55a60926_default/index.html?playlistId=4201918719001"
        
    initTheme: initTheme
    
    SetId       : function(x) : m.sessid = x : end function
    GetId       : function() : return m.sessid : end function
    
    sessid: ""
    session_name: ""
  }
  return this

End Function