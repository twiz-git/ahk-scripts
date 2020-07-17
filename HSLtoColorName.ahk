HSLtoColorName(_H, _S, _L, UsePrefix=0) {
	If (_S >= .15) AND (_L >= .1) AND (_L <=.94) {
		If _H < 15
			Color := "Red"
		Else If _H < 40
			Color := "Orange"
		Else If _H < 77
			Color := "Yellow"
		Else If _H < 150
			Color := "Green"
		Else If _H < 200
			Color := "Cyan"
		Else If _H < 230
			Color := "Blue"
		Else If _H < 300
			Color := "Indigo"
		Else If _H < 350
			Color := "Magenta"
		Else
			Color := "Red"

		If (UsePrefix) {
			If _S < .5
				Prefix .= "Pale "
			If _L < .4
				Prefix .= "Dark "
			Else If _L > .6
				Prefix .= "Light "
		}

	} Else {
		If _L < .25
			Color := "Black"

		Else If _L between .2 and .8
		{
			Color := "Gray"
			If (UsePrefix) {
				If _L < .4
					Prefix .= "Dark "
				Else If _L > .6
					Prefix := "Light "
			}
		}
		Else If _L > .8
			Color := "White"
	}
	Return Prefix Color
}