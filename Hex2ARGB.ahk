Hex2ARGB(Hex, Alpha=1) {
	If Hex is not xdigit
		Return ERROR

	If SubStr(Hex, 1, 2) = "0x"
		Hex := SubStr(Hex, 3)

	If StrLen(Hex) = 8
		A := "0x" SubStr(Hex, 1, 2)

	R := "0x" SubStr(Hex, -5, 2)
	G := "0x" SubStr(Hex, -3, 2)
	B := "0x" SubStr(Hex, -1, 2)
	
	If Alpha
	{
		If !A
			A := 0xFF
		Return (A << 24) + (R << 16) + (G << 8) + B
	} Else
		Return (R << 16) + (G << 8) + B
}