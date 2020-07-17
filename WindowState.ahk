WindowState(Word=0) {
/*	Returns a value based on the Window State:
	1	if the window is maximized.
	0	if the window is not maximized.
	-1	if the window is in Fullscreen mode.
*/
	WinGet, WinStyle, Style, A
	If (WinStyle & 0xC00000) {
		WinGet, WinMinMax, MinMax, A
		If WinMinMax
			Return Word ? "m" : 1
		Else
			Return Word ? "w" : 0
	} Else {
		Return Word ? "f" : -1
	}
}