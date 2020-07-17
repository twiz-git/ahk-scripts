RGBtoHSL(_RGB, ByRef _H, ByRef _S, ByRef _L) {
;	Formulas taken from https://www.rapidtables.com/convert/color/rgb-to-hsl.html
	If _RGB is not xdigit
	{
		MsgBox,, ERROR: Invalid RGB Value., The RGB value must contain only numbers (0-9) and valid Hexadecimal`nletters (A-F, case insensitive), and optionally have an 0x prefix.`nValid examples are:`n•`t"ABC123`"`n•`t`"0xD4E5F6`"
		Return
	}
	;	Check '0x' Prefix
	If (SubStr(_RGB, 1, 2) != "0x")
		_RGB := "0x" _RGB

    R := (_RGB >> 16 & 0xFF) / 255
    G := (_RGB >> 8 & 0xFF) / 255
    B := (_RGB & 0xFF) / 255
	Max := Max(R, G, B)
	Min := Min(R, G, B)
	Chroma := Max - Min

	;	Calculate Hue
	If (Chroma = 0)
		_H := 0
	Else If (Max = R)
		;Hue = Mod((G - B) / Chroma, 6)
		_H := (G - B) / Chroma + (G < B ? 6 : 0)
	Else If (Max = G)
		_H := (B - R) / Chroma + 2
	Else If (Max = B)
		_H := (R - G) / Chroma + 4
	_H := _H * 60

	;	Calculate Lightness
	_L := (Max + Min) / 2

	;	Calculate Saturation
	If (Chroma = 0)
		_S := 0
	Else
		_S := Chroma / (1 - Abs(2 * _L - 1))
}
