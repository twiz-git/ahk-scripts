#SingleInstance, Force	; Allow only one instance of the script to run
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
#Persistent	; Keep the script 'alive' in the tray

; Convert Minutes to Miliseconds
UpdateTimer := 60000 * 1  ; Set time values in Minutes
MaxIdleTime := 60000 * 10 ; 60000 miliseconds = 1 minute
RemoteIPAddress := "192.168.1.110"  ; IP address of device you stream to

; Create a repeating Timer to check if Idle
SetTimer, CheckIdle, %UpdateTimer%
Return


; Check if host PC is idle
CheckIdle:
	; If it is idle, Ping remote client to check state
	If (A_TimeIdle > MaxIdleTime) {
		If IsOnline(RemoteIPAddress) {
			; If the remote client is on, reset idle time
			MouseMove, 0, 0, 0, R	; Moves the mouse cursor 0px by 0px, with 0 delay, [R]elative to it's current position
		} Else {
			; If the remote client is off, sleep host
			/*	DO NOT use "rundll32.exe" to call "powrprof.dll"\SetSuspendState due to differences
			in argument syntax between what "rundll32.exe" requires, and what "powrprof.dll" uses.
			Source:				https://blogs.msdn.microsoft.com/oldnewthing/20040115-00/?p=41043/
			Rundll32.exe:		https://technet.microsoft.com/en-us/library/ee649171(v=ws.11).aspx
			SetSuspendState:	https://msdn.microsoft.com/en-us/library/aa373201(v=ws.85).aspx
			*/
			DllCall("PowrProf.dll\SetSuspendState", "Int", FALSE, "Int", FALSE, "Int", FALSE)
		}
	}
Return


; Check online status
IsOnline(ip:="8.8.8.8") {	; Default IP is Google Public DNS to test internet connection
	; WshShell object: https://msdn.microsoft.com/en-us/library/aew9yb99(v=vs.84).aspx
	Shell := ComObjCreate("WScript.Shell")
	; Backup Clipboard contents
	ClipData := ClipboardAll
	; Run Ping command via cmd.exe (Comspec) and copy it to Clipboard
	Exec := shell.Run(Comspec " /c ping -n 1 " ip "|Clip", 0, true)
	; Check the output of Ping for the "TTL", this means there was a reachable response
	IfInString, Clipboard, TTL
		Result := 1
	Else
		Result := 0
	; Restore Clipboard contents
	Clipboard := ClipData
	Return % Result
}
