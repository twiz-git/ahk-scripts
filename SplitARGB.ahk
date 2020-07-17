/*		SplitARGB()
_ColorIn	-	The input 6 bit RGB/BGR or 8 bit ARGB/ABGR hexadecimal color value, "0x" prefix optional
_OutVarName	-	Output information is stored in four variables whose names start with the chosen variable
_UseBGR		-	[OPTIONAL] Use BGR ordering instead of RGB, use 1 (quoted or unquoted) or TRUE (unquoted only)

*****	SAMPLE INPUT	*****
SplitARGB("2288ff", "MyColor", 1)

*****	SAMPLE OUTPUT	*****
MyColorA = "" (blank)
MyColorR = 255
MyColorG = 136
MyColorB = 34
*/

SplitARGB(_ColorIn, _OutVarName, _UseBGR=0) {
	; Ensure the _ColorIn is a hexadecimal value
	If _ColorIn is not xdigit
	{
		MsgBox, Input was not a hexadecimal number.`n%_ColorIn%
		Return
	}
	
	;	Count the length, minus 0x prefix
	If SubStr(_ColorIn, 1, 2) = "0x"
		_StrLen := StrLen(SubStr(_ColorIn, 3))
	Else {
		_StrLen := StrLen(_ColorIn)
		_ColorIn := "0x" _ColorIn
		_ColorIn += 0
	}

	If (_StrLen != 6) AND (_StrLen != 8)
	{
		MsgBox, Incorrect string length.`n%_ColorIn%
		Return
	}

	;	Set byte order
	If (_UseBGR = 1)
		_Rb := 0, _Bb := 16
	Else
		_Rb := 16, _Bb := 0
	
	If (_StrLen = 8)
	%_OutVarName%A := _ColorIn >> 24	& 0xFF
    %_OutVarName%R := _ColorIn >> _Rb	& 0xFF
    %_OutVarName%G := _ColorIn >> 8		& 0xFF
    %_OutVarName%B := _ColorIn >> _Bb	& 0xFF
}