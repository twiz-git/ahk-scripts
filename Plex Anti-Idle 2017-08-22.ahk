#SingleInstance, Force	; Allow only one instance of the script to run
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent	; Keep the script 'alive' in the tray

;Mutlitply the value by 60000 to use minutes (1,000ms = 1sec, 60,0000ms = 60 sec)
UpdateTimer := 60000 * 5
MaxIdleTime	:= 60000 * 10

PlexIP		:= "127.0.0.1"
PlexPort	:= "32400"
PlexToken	:= "PasteYourTokenHere"
PlexURL		:= "http://" PlexIP ":" PlexPort "/status/sessions?X-Plex-Token=" PlexToken

; Create a repeating Timer to check if Idle
SetTimer, CheckIdle, %UpdateTimer%
Return


CheckIdle:
	; Check if host PC has been idle more than X minutes
	If (A_TimeIdle > MaxIdleTime) {
		UserCount := ""

		; Try to send an HTTP request to the Plex Server
		Try {
			hObject := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			hObject.Open("GET", PlexURL)
			hObject.Send()
			Response := hObject.ResponseText
		; Catch any errors, if there is one, and exit
		} Catch e {
			MsgBox, 4,, Could not connect to the Plex server.`nPlease check that your Plex configuration and information here is correct, and that your server is running.`nThis application will exit after closing this box.`n`nDo you wish to view the error message?
			IfMsgBox, Yes
				MsgBox % e.Message	; Display the HTTP error message
			ExitApp
		}

		; Get the number of connected users if the response contains the word "MediaContainer"
		If InStr(Response, "MediaContainer") {
			UserCount := RegExReplace(Response, "is).*<MediaContainer size=""(\d+)"">.*", "$1")
			If (UserCount > 0) {
				; If the Plex server has connected users, we reset idle computers time by "moving"
				; the mouse cursor 0px by 0px, with 0 delay, [R]elative to it's current position
				MouseMove, 0, 0, 0, R
		; If the response contains the word "Unauthorized", display this message and exit
		} Else If InStr(Response, "Unauthorized") {
			MsgBox,, % RegExReplace(Response, "is).*<body>.*?<h1>(.*?)</h1>.*?</body>.*", "$1"), It appears your Plex Token is invalid.`nPlease check that your Plex Token is correct and run the app again.
			ExitApp
		; If the response doesn't contain either of the above, then us me know
		} Else {
			MsgBox,, Unknown response from server, %Response%
		}
	}
Return
