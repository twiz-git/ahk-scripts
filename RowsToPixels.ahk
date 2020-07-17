RowsToPixels(r, h=0){
	px := (r * 19) + 19
	If (h > 0)
		px += (h - 1) * 19 + 10
	Return px
}