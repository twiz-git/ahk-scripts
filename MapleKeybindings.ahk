#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

If not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
	ExitApp
}

#IfWinActive, ahk_class MapleStoryClass
~c::Send, '{backspace}	;	Open/close Equipment['] and Ability[C] windows
NumpadAdd::Click, 655, 774	; Cash Shop button

;	Change window size
F1::ResizeMS(1366, 768)		; i:1366x768	o:1372x979
F2::ResizeMS(1920, 1017)	; i:1920x1017	o:1926x1046
F3::CycleVPos()
F4::CycleHPos()
F5::
	WinID := WinExist("A")
	WinRestore, AHK_ID %WinID%
	If !%WinID% {
		%WinID% := 1
		DllCall("SetWindowLongPtrA", "uInt", WinExist("A"), "Int", -16, "uInt", 0x14000000)
		WinMaximize, AHK_ID %WinID%
	} Else {
		%WinID% := 0
		DllCall("SetWindowLongPtrA", "uInt", WinExist("A"), "Int", -16, "uInt", 0x14CB0000)
	}
	WinSet, Redraw,, A
Return


ResizeMS(W, H, X=0, Y=0) {
	SysGet, TitleH, 4	; SM_CYCAPTION	- Titlebar Height
	SysGet, BorderX, 7	; SM_CXFIXEDFRAME	- Border Width
	SysGet, BorderY, 8	; SM_CYFIXEDFRAME	- Border Height

	W := W + (BorderX * 2)
	H := H + (BorderY * 2 + TitleH)
	;WinSet, Style, 0x14CB0000, A	; MapleStory doesn't like AHK's "WinSet, Style", so use below DLLCall
	DllCall("SetWindowLongPtrA", "uInt", WinExist("A"), "Int", -16, "uInt", 0x14CB0000)	; Same as "WinSet, Style"
	WinSet, Redraw,, A	; Redraw the window to fix title bar graphics glitch
	WinMove, A,, 0, 0, %W%, %H%
}


CycleHPos(pos="") {
	SysGet, Mon, MonitorWorkArea
	WinGetPos, X, Y, W, H, A
	HPosR := MonRight - W
	HPosM := HPosR / 2
	HPosL := HPosR / 3
	If (X <= HPosL)
		WinMove, A,, %HPosM%
	Else If (X <= HPosM) ;OR (X > HPosL)
		WinMove, A,, %HPosR%
	Else
		WinMove, A,, 0
}

CycleVPos(pos="") {
	SysGet, Mon, MonitorWorkArea
	WinGetPos, X, Y, W, H, A
	VPosB := MonBottom - H
	VPosM := VPosB / 2
	VPosT := VPosB / 3
	If (Y <= VPosT)
		WinMove, A,,, %VPosM%
	Else If (Y <= VPosM) ;OR (Y > VPosT)
		WinMove, A,,, %VPosB%
	Else
		WinMove, A,,, 0
}
