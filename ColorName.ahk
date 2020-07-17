#SingleInstance, Force	;	Allow only one running instance, relaunches on new instance
#Persistent	;	Keep the script 'alive' in the tray
#NoEnv	;	Recommended for performance and compatibility with future AutoHotkey releases
SetWorkingDir, %A_ScriptDir%	;	Ensures a consistent starting directory

Gui, Add, Text, w100 r5 vColorText
Gui, +AlwaysOnTop -MinimizeBox
Gui, Show, w125
SetTimer, Update, 250
Return

GuiClose:
ExitApp

Update:
	MouseGetPos, _xPos, _yPos
	PixelGetColor, _pRGB, _xPos, _yPos, RGB
	RGBtoHSL(_pRGB, _H, _S, _L)
	_cName := HSLtoColorName(_H, _S, _L, 0)
	GuiControl, % _L <= 0.25 ? "+cFFFFFF" : "+c000000", ColorText
	GuiControl, Text, ColorText, % _cName "`nRGB:`t" _pRGB "`nHue:`t" _H "`nSat:`t" _S "`nLight:`t" _L
	Gui, Color, %_pRGB%
Return

