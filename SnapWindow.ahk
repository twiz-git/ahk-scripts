; HookProc and API_SetWinEventHook by majkinetor
; http://www.autohotkey.com/board/topic/20714-tutorial-winevent-hook/
/*	To do:
- Fix distance on Windows 10, get/use Border size?
- Add excluded windows?
- Add movement check and alternate methods of moving
*/
#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Recommended for catching common errors.
#Persistent
SendMode, Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir, %A_ScriptDir%  ; Ensures a consistent starting directory.
iniFile := A_ScriptDir "\settings.ini"

iniRead, Range, %iniFile%, Global, Range, 15	; Distance inside work area to snap
iniRead, Multi, %iniFile%, Global, Multi, 10	; Distance multiplier outside of work area

HookProcAdr := RegisterCallback("HookProc", "F" ), 0,0
API_SetWinEventHook(0xA, 0xB, 0, HookProcAdr, 0, 0, 0)
Return


HookProc(hWinEventHook, event, hwnd, idObject, idChild, dwEventThread, dwmsEventTime) {
	Global Range, Multi
	If (event = 11) { ; Window Moving event stopped
		GetWorkArea(WorkX, WorkY, WorkW, WorkH) ; Get the Desktop work area
		WinGetActiveStats, Title, WinW, WinH, WinX, WinY ; Get the Active window title, dimensions, and position.
		DoSnap := 0

		If (WinW < WorkW) AND (WinH < WorkH) {
			If (WinX < WorkX + Range) ; Left edge
			&& (WinX > WorkX - (Range * Multi)) {
				WinX := WorkX
				DoSnap := 1
			}
			If (WinX + WinW < WorkW + (Range * Multi)) ; Right edge
			&& (WinX + WinW > WorkW - Range) {
				WinX := WorkW - WinW
				DoSnap := 1
			}
			If (WinY < WorkY + Range) ; Top edge
			&& (WinY > WorkY - (Range * Multi)) {
				WinY := WorkY
				DoSnap := 1
			}
			If (WinY + WinH < WorkH + (Range * Multi)) ; Bottom edge
			&& (WinY + WinH > WorkH - Range) {
				WinY := WorkH - WinH
				DoSnap := 1
			}
		}

		If DoSnap {
			;MsgBox WinMove, %Title%,, %WinX%, %WinY%
			WinMove, A,, WinX, WinY
		}
	}
}

API_SetWinEventHook(eventMin, eventMax, hmodWinEventProc, lpfnWinEventProc, idProcess, idThread, dwFlags) {
	DllCall("CoInitialize", "uint", 0)
	Return DllCall("SetWinEventHook", "uint", eventMin, "uint", eventMax, "uint", hmodWinEventProc, "uint", lpfnWinEventProc, "uint", idProcess, "uint", idThread, "uint", dwFlags)
}


GetWorkArea(ByRef _WA_X, ByRef _WA_Y, ByRef _WA_W, ByRef _WA_H, ByRef _TB_Pos = "") {
	SysGet, Mon, Monitor
	WinGetPos, _TB_X, _TB_Y, _TB_W, _TB_H, ahk_class Shell_TrayWnd

	If (_TB_W = MonRight) { ; Horizontal
		If (_TB_Y > 0) { ; Bottom
			_WA_Y := 0
			_WA_H := MonBottom - _TB_H
			_TB_Pos := "Bottom"
		} Else { ; Top
			_WA_Y := _TB_H
			_WA_H := MonBottom
			_TB_Pos := "Top"
		}
		_WA_X := 0
		_WA_W := _TB_W
	} Else If (_TB_H = MonBottom) { ; Vertical
		If (_TB_X > 0) { ; Right
			_WA_X := 0
			_WA_W := MonRight - _TB_W
			_TB_Pos := "Right"
		} Else { ; Left
			_WA_X := _TB_W
			_WA_W := MonRight
			_TB_Pos := "Left"
		}
		_WA_Y := 0
		_WA_H := _TB_H
	}
}