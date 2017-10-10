#SingleInstance, Force	; Allow only one instance of the script to run
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent	; Keep the script 'alive' in the tray

iniFile := A_AppData "\PlexAntiIdle.ini"
iniRead, TimerMins,	%iniFile%, Plex, TimerMinutes, 5
iniRead, IdleMins,	%iniFile%, Plex, IdleMinutes, 10
iniRead, PlexIP,	%iniFile%, Plex, PlexIP, 127.0.0.1
iniRead, PlexPort,	%iniFile%, Plex, PlexPort, 32400
;iniRead, PlexToken,	%iniFile%, Plex, PlexToken
PlexToken	:= "PasteYourTokenHere"
PlexURL		:= "http://" PlexIP ":" PlexPort "/status/sessions?X-Plex-Token=" PlexToken

;Mutlitply the value by 60000 to use minutes (1,000ms = 1sec, 60,0000ms = 60 sec)
UpdateTimer := 60000 * TimerMins
MaxIdleTime	:= 60000 * IdleMins

Debug		:= 0
DebugLog	:= A_Desktop "\Plex AntiIdle Log.txt"


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
			MsgBox, 16,, % e.Message	; Display the HTTP error message
			ExitApp
		}

		; Get the number of connected users if the response contains the word "MediaContainer"
		If InStr(Response, "MediaContainer") {
			UserCount := RegExReplace(Response, "is).*<MediaContainer size=""(\d+)"">.*", "$1")
			If %Debug%
				Gosub Debug
			If (UserCount > 0) {
				; If the Plex server has connected users, we reset computers idle time
				; https://msdn.microsoft.com/en-us/library/aa373208(VS.85).aspx
				DllCall("Kernel32.dll\SetThreadExecutionState", "Int", 0x00000001)
			}

		
		; If the response contains the word "Unauthorized", display this message and exit
		} Else If InStr(Response, "Unauthorized") {
			;RegExReplace(Response, "is).*<body>.*?<h1>(.*?)</h1>.*?</body>.*" "$1")
			
			MsgBox,, Error - Unauthorized, % TimeStamp() "	Unauthorized`n`nIt appears your Plex Token is invalid.`nPlease check that your Plex Token is correct and run the app again."
			ExitApp
		; If the response doesn't contain either of the above, then us me know
		} Else {
			MsgBox,, Error - Unknown, % TimeStamp() "	Unknown response from server`n`n" Response
		}
	}
Return


Debug:
	Title := ""
	If (UserCount > 0)
		Title := "	" RegExReplace(Response, "is).*<Video.*?title=""(.+?)"" .*", "$1")
	FileAppend, % TimeStamp() "	[" UserCount "]" Title "`n", %DebugLog%
Return

TimeStamp() {
	FormatTime, CurrentTime,, yyyy-MM-dd HH:mm
	Return %CurrentTime%
}
