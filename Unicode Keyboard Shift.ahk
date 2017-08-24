#SingleInstance, Force
SetFormat, Integer, Hex

Loop, 26 {
	_Code := A_Index + 0x40
	Hotkey, % Format("vk{:02x}", _Code), Press1, On
	Hotkey, % "+" Chr(_Code + 0x20), Press2, On
}
Return

Press1:
	_Key := "0x" SubStr(A_ThisHotkey,3)
	Clipboard := Chr(_Key + 0x1D51E - 0x41)
	Send, ^v
Return

Press2:
	Clipboard := Chr(GetKeyVK(SubStr(A_ThisHotkey, 2)) + 0x1D504 - 0x41)
	Send, ^v
Return

`::Suspend



/*	https://unicode-table.com/en/blocks/mathematical-alphanumeric-symbols/
0x00041 - 0x0005A	Latin Upper Case
0x00061 - 0x0007A	Latin Lower Case

0x0FF00 - 0x0FF20	Full-Width Symbols 
0x0FF21 - 0x0FF3A	Full-Width Upper Case
0x0FF41 - 0x0FF5A	Full-Width Lower Case

0x1D504 - 0x1D51D	Fraktur Upper Case
0x1D51E - 0x1D537	Fraktur Lower Case

0x1D56C - 0x1D585	Bold Fraktur Upper Case
0x1D586 - 0x1D59F	Bold Fraktur Lower Case
