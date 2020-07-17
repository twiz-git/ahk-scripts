#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


If %0% {
	Loop %0%
		Loop, % %A_Index%
			_list .= A_LoopFileLongPath "`n"
	Sort, _list
	Loop, Parse, _list, `n
		If A_LoopField
		;&& InStr(A_LoopField, ".txt")
			_file := A_LoopField
} Else {
	Loop, Files, %A_ScriptDir%\*
		_file := A_LoopFileLongPath
}

MsgBox % _file