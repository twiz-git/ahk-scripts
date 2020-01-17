#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode, Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
CoordMode, Mouse, Client

If not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
	ExitApp
}

#IfWinActive, ahk_class MapleStoryClass
*PrintScreen::Return

~c::Send, '{backspace}	;	Open/close Equipment['] and Ability[C] windows
NumpadAdd::Click, 655, 750	; Cash Shop button

!Numpad1::
!Numpad2::
!Numpad3::
!Numpad4::
!Numpad5::
!Numpad6::
!Numpad7::
!Numpad8::
!Numpad9::
	WinPos(SubStr(A_ThisHotkey, 0, 1))
Return

F5::	;	Maximize/Restore window
	WinID := WinExist("A")
	WinRestore, AHK_ID %WinID%
	If !%WinID% {
		%WinID% := 1
		;WinSet, Style, 0x14000000, A	; MapleStory doesn't like AHK's "WinSet, Style", so use the DLLCall below
		DllCall("SetWindowLongPtrA", "uInt", WinExist("A"), "Int", -16, "uInt", 0x14000000)	; Same as "WinSet, Style"
		WinMaximize, AHK_ID %WinID%
	} Else {
		%WinID% := 0
		;WinSet, Style, 0x14000000, A	; MapleStory doesn't like AHK's "WinSet, Style", so use the DLLCall below
		DllCall("SetWindowLongPtrA", "uInt", WinExist("A"), "Int", -16, "uInt", 0x14CB0000)	; Same as "WinSet, Style"
	}
Return


WinPos(pos=0) {
	SysGet, Mon, MonitorWorkArea
	WinGetPos,,, W, H, A
	xPos := (MonRight - W) / 2
	yPos := (MonBottom - H) / 2

	If (pos = 1) OR (pos = 4) OR (pos = 7)
		xPos := 0
	Else If (pos = 3) OR (pos = 6) OR (pos = 9)
		xPos := (MonRight - W)
	Else
		xPos := (MonRight - W) / 2
	
	If (pos = 7) OR (pos = 8) OR (pos = 9)
		yPos := 0
	Else If (pos = 1) OR (pos = 2) OR (pos = 3)
		yPos := (MonBottom - H)
	Else
		yPos := (MonBottom - H) / 2
	
	WinMove, A,, %xPos%, %yPos%
}
