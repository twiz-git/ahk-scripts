#SingleInstance, Force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
SetFormat, Integer, Hex


If not A_IsAdmin
{
	Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
	ExitApp
}


_StyleList := {0xC0000000: "0x80000000 - N/A"
,	0x80000000: "WS_POPUP"
,	0x40000000: "WS_CHILD"
,	0x20000000: "WS_MINIMIZE"
,	0x10000000: "WS_VISIBLE"

,	0x0C000000: "0x0C000000 - N/A"
,	0x08000000: "WS_DISABLED"
,	0x04000000: "WS_CLIPSIBLINGS"
,	0x02000000: "WS_CLIPCHILDREN"
,	0x01000000: "WS_MAXIMIZE"

,	0x00C00000: "WS_CAPTION"
,	0x00800000: "WS_BORDER"
,	0x00400000: "WS_DLGFRAME"
,	0x00200000: "WS_VSCROLL"
,	0x00100000: "WS_HSCROLL"

,	0x000C0000: "0x000C0000 - N/A"
,	0x00080000: "WS_SYSMENU"
,	0x00040000: "WS_SIZEBOX"
,	0x00020000: "WS_MINIMIZEBOX"
,	0x00010000: "WS_MAXIMIZEBOX"}

_StyleIndex := []
n := _StyleList.Count()
For Key, Value in _StyleList	; Key = hex, Value = name
{
	_StyleIndex[n] := Key
	n -= 1
}


xPos := 10
yPos := 18
Gui, +AlwaysOnTop
Gui, Add, GroupBox, Section w525 r5 v_GroupBox, Window Style
Loop, % _StyleList.Count()
{
	vIndex := _StyleIndex[A_Index]
	Gui, Add, Checkbox, xs%xPos% ys%yPos% v_Var%vIndex%, % _StyleList[_StyleIndex[A_Index]]

	yPos += 19
	n += 1
	If (n >= 5) {
		n := 0
		xPos += 125
		yPos := 18
	}
}
Return


GuiClose:
	Gui, Hide
Return


F12::
	SysGet, _Mon, MonitorWorkArea
	WinGet, _WinStyle, Style, A
	WinGetTitle, _WinTitle, A

	GuiControl,, _GroupBox, %_WinStyle% - %_WinTitle%
	_temp := _WinStyle
	
	For key, value in _StyleList {	; key = hex, value = name
		vIndex := _StyleIndex[A_Index]
		If (_temp >= vIndex) {
			_temp -= vIndex
			GuiControl,, _Var%vIndex%, 1
		} Else {
			GuiControl,, _Var%vIndex%, 0
		}
	}
	
	WinXPos := (_MonRight - 551) / 2
	Gui, Show, NA x%WinXPos% y0
	If (_temp > 0)
		MsgBox % _temp
Return



/*	Window Style List	--	https://docs.microsoft.com/en-us/windows/win32/winmsg/window-styles
WS_BORDER			0x00800000		The window has a thin-line border.
WS_CAPTION			0x00C00000		The window has a title bar (includes the WS_BORDER style).
WS_CHILD			0x40000000		The window is a child window. A window with this style cannot have a menu bar. This style cannot be used with the WS_POPUP style.
WS_CHILDWINDOW		0x40000000		Same as the WS_CHILD style.
WS_CLIPCHILDREN		0x02000000		Excludes the area occupied by child windows when drawing occurs within the parent window. This style is used when creating the parent window.
WS_CLIPSIBLINGS		0x04000000		Clips child windows relative to each other; that is, when a particular child window receives a WM_PAINT message, the WS_CLIPSIBLINGS style clips all other overlapping child windows out of the region of the child window to be updated. If WS_CLIPSIBLINGS is not specified and child windows overlap, it is possible, when drawing within the client area of a child window, to draw within the client area of a neighboring child window.
WS_DISABLED			0x08000000		The window is initially disabled. A disabled window cannot receive input from the user. To change this after a window has been created, use the EnableWindow function.
WS_DLGFRAME			0x00400000		The window has a border of a style typically used with dialog boxes. A window with this style cannot have a title bar.
WS_GROUP			0x00020000		The window is the first control of a group of controls. The group consists of this first control and all controls defined after it, up to the next control with the WS_GROUP style. The first control in each group usually has the WS_TABSTOP style so that the user can move from group to group. The user can subsequently change the keyboard focus from one control in the group to the next control in the group by using the direction keys. You can turn this style on and off to change dialog box navigation. To change this style after a window has been created, use the SetWindowLong function.
WS_HSCROLL			0x00100000		The window has a horizontal scroll bar.
WS_ICONIC			0x20000000		The window is initially minimized. Same as the WS_MINIMIZE style.
WS_MAXIMIZE			0x01000000		The window is initially maximized.
WS_MAXIMIZEBOX		0x00010000		The window has a maximize button. Cannot be combined with the WS_EX_CONTEXTHELP style. The WS_SYSMENU style must also be specified.
WS_MINIMIZE			0x20000000		The window is initially minimized. Same as the WS_ICONIC style.
WS_MINIMIZEBOX		0x00020000		The window has a minimize button. Cannot be combined with the WS_EX_CONTEXTHELP style. The WS_SYSMENU style must also be specified.
WS_OVERLAPPED		0x00000000		The window is an overlapped window. An overlapped window has a title bar and a border. Same as the WS_TILED style.
WS_OVERLAPPEDWINDOW	(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)	The window is an overlapped window. Same as the WS_TILEDWINDOW style.
WS_POPUP			0x80000000		The windows is a pop-up window. This style cannot be used with the WS_CHILD style.
WS_POPUPWINDOW		(WS_POPUP | WS_BORDER | WS_SYSMENU)		The window is a pop-up window. The WS_CAPTION and WS_POPUPWINDOW styles must be combined to make the window menu visible.
WS_SIZEBOX			0x00040000		The window has a sizing border. Same as the WS_THICKFRAME style.
WS_SYSMENU			0x00080000		The window has a window menu on its title bar. The WS_CAPTION style must also be specified.
WS_TABSTOP			0x00010000		The window is a control that can receive the keyboard focus when the user presses the TAB key. Pressing the TAB key changes the keyboard focus to the next control with the WS_TABSTOP style. You can turn this style on and of to change dialog box navigation. To change this style after a window has been created, use the SetWindowLong function. For user-created windows and modeless dialogs to work with tab stops, alter the message loop to call the IsDialogMessage function.
WS_THICKFRAME		0x00040000		The window has a sizing border. Same as the WS_SIZEBOX style.
WS_TILED			0x00000000		The window is an overlapped window. An overlapped window has a title bar and a border. Same as the WS_OVERLAPPED style.
WS_TILEDWINDOW		(WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX)		The window is an overlapped window. Same as the WS_OVERLAPPEDWINDOW style.
WS_VISIBLE			0x10000000		The window is initially visible. This style can be turned on and ff by using the ShowWindow or SetWindowPos function.
WS_VSCROLL			0x00200000		The window has a vertical scroll bar.
