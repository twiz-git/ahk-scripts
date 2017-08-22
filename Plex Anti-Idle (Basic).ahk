#SingleInstance, Force	; Allow only one instance of the script to run
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent	; Keep the script 'alive' in the tray

;Mutlitply the value by 60000 to use minutes (1,000ms = 1sec, 60,0000ms = 60 sec)
UpdateTimer	:= 60000 * 5
MaxIdleTime	:= 60000 * 10
IPAddress	:= "127.0.0.1"

; Create a repeating Timer to check if Idle
SetTimer, CheckIdle, %UpdateTimer%
Return


CheckIdle:
	; Check if host PC has been idle more than X minutes
	If (A_TimeIdle > MaxIdleTime) {
		; If idle, ping remote client to check state
		If IsOnline(IPAddress) {
			; If the remote client is on, we reset idle time by "moving" the mouse
			; cursor 0px by 0px, with 0 delay, [R]elative to it's current position
			MouseMove, 0, 0, 0, R
		}
	}
Return


; Check online status
IsOnline(ip:="8.8.8.8") {	; Default IP is Google Public DNS to test internet connection
	; WshShell object: https://msdn.microsoft.com/en-us/library/aew9yb99(v=vs.84).aspx
	Shell := ComObjCreate("WScript.Shell")
	; Backup Clipboard contents
	ClipData := ClipboardAll
	; Run Ping command via cmd.exe (Comspec) and copy it to Clipboard using Clip.exe
	Exec := shell.Run(Comspec " /c ping -n 1 " ip "|Clip.exe", 0, true)
	; Check the output of Ping for "TTL", this means there was a reachable response
	IfInString, Clipboard, TTL
		Result := 1
	Else
		Result := 0
	; Restore Clipboard contents
	Clipboard := ClipData
	Return % Result
}
