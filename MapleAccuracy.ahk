#SingleInstance, Force
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn	; Recommended for catching common errors.
SetWorkingDir, %A_ScriptDir%

;If !FileExist(A_ScriptDir "\eAutocomplete.ahk")
;	URLDownloadToFile, https://raw.githubusercontent.com/A-AhkUser/eAutocomplete/master/eAutocomplete.ahk, %A_ScriptDir%\eAutocomplete.ahk


/**********		TO DO:		**********
	1). Fix Melee Accuracy
	2). Magician Variable Accuracy
	3). Write values to INI file
	4). Read/Parse Monster List Database
	5). Add Monster List Autocomplete
*/


SplitView := 0

edtW	:= 100
guiW	:= 110 + edtW
edtX	:= guiW - edtW - 9
btnW	:= 60
btnH	:= 23 ; Default = 23
Gosub ReadINI


BuffList := "
(
   -5  Cider|
    5  Sniper Potion|
    9  Thief Elixir|
  10  Candy/Candy Basket|
  10  Sniper Pill|
  20  Bless|
  30  Banana Graham Pie|
  30  Chocolate Cream Cupcake|
  30  Gelt Chocolate|
  40  Amorian Basket|
  50  Heartstopper|
  50  Maple Syrup|
100  Maple Pop|
100  GM Bless|
)"

guiH1 := editHeight(4)
Gui, Add, GroupBox, Section w%guiW% h%guiH1%, Character Stats
Gui, Add, Text,	xs+10 ys+19, Character Type:
Gui, Add, DDL,	xs+%edtX% yp-3 w%edtW% vpType gGuiUpdate, Magician|Non-Magician||
Gui, Add, Text, xs+10 y+8, Character Level:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vpLvl, %pLvl%
Gui, Add, Text, xs+10 y+8 vText1, Character ####:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vpInt, %pInt%
Gui, Add, Edit, xs+%edtX% yp w%edtW% vpAcc, %pAcc%
Gui, Add, Text, xs+10 y+8 vText2, Character ####:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vpLuk, %pLuk%
Gui, Add, DDL, xs+%edtX% yp w%edtW% hwndDDLID vpBuffName gSetBuff, %BuffList%
SendMessage, 0x0160, 150, 0, , ahk_id %DDLID%

guiH2 := editHeight(3)
Gui, Add, GroupBox, Section xs w%guiW% h%guiH2%, Monster Stats
Gui, Add, Text, xs+10 ys+19, Monster Name:
Gui, Add, DDL, xs+%edtX% yp-3 w%edtW% +Disabled, Soon™||
Gui, Add, Text, xs+10 y+8, Monster Level:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vmLvl, %mLvl%
Gui, Add, Text, xs+10 y+8, Monster Evade:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vmEva, %mEva%

guiH3 := editHeight(5)
If %SplitView% {
	SctW := guiW + 8
	Gui, Add, GroupBox, Section xs+%SctW% y6 w%guiW% h%guiH3%, Calculations	; Split view
} Else
	Gui, Add, GroupBox, Section xs w%guiW% h%guiH3%, Calculations
Gui, Add, Text, xs+10 ys+19, Total Accuracy:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% +ReadOnly vtotAcc,
Gui, Add, Text, xs+10 y+8, Your Hit Rate:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% +ReadOnly vhitRate,
Gui, Add, Text, xs+10 y+8, Acc. for 100`% Hit:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% +ReadOnly vmaxAcc,

Gui, Add, Text, xs+10 y+8 vSliderText, Acc. for ###`% Hit:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% +ReadOnly vpctAcc,
SldW := guiW - 8
Gui, Add, Slider, xs+4 y+8 w%SldW% h20 AltSubmit +TickInterval10 gAccSlider vsPct +0x400, %sPct%

nBtn	:= 3
btnG	:= (guiW - (btnW * nBtn)) / (nBtn + 3)
bXPos	:= btnG * 2
bYPos	:= (guiH1 + guiH2) - Floor(guiH3 + btnH / 2)	; Split view
If %SplitView% {
	Gui, Add, Button, xs+%bXPos% y+%bYPos% w%btnW% h%btnH% +Default gCalculate, Calculate	; Split view
} Else {
	Gui, Add, Button, xs+%bXPos% w%btnW% h%btnH% +Default gCalculate, Calculate
}
Gui, Add, Button, x+%btnG% w%btnW% gReset, Reset
Gui, Add, Button, x+%btnG% w%btnW% gClear, Clear

Gosub, GuiUpdate
Gui, Show
Return

GuiClose:
ExitApp

GuiUpdate:
	Gui, Submit, NoHide
	If (pType = "Magician") {
		GuiControl, Text, Text1, Character INT:
		GuiControl, Text, Text2, Character LUK:
		
		GuiControl, Show, pInt
		GuiControl, Show, pLuk
		GuiControl, Hide, pAcc
		GuiControl, Hide, pBuff
		
	} Else {
		GuiControl, Text, Text1, Character Acc:
		GuiControl, Text, Text2, Accuracy Buff:
		
		GuiControl, Hide, pInt
		GuiControl, Hide, pLuk
		GuiControl, Show, pAcc
		GuiControl, Show, pBuff
	}
AccSlider:
	Gui, Submit, NoHide
	GuiControl, Text, SliderText, Acc. for %sPct%`% Hit:
Return

SetBuff:
	Gui, Submit, NoHide
	If (pBuffName = "")
		pBuff := 0
	Else
		pBuff := RegExReplace(pBuffName, "\s*(.?\d+).*", "$1")
Return

Calculate:
	Gui, Submit, NoHide
	Gosub, SetBuff
	LvlDiff := mLvl - pLvl
	If (LvlDiff < 0)
		LvlDiff := 0

	If (pType = "Magician") {
		totAcc	:= Floor(pInt / 10) + Floor(pLuk / 10)
		maxAcc	:= Ceil((mEva + 1) * (1 + 0.04 * LvlDiff))
		pctAcc	:= "Soon™"
		minAcc	:= Ceil(0.41 * maxAcc)
		
		fncAcc	:= (totAcc - minAcc + 1) / (maxAcc - minAcc + 1)
		hitRate	:= Round((-0.7011618132 * (fncAcc**2) + 1.702139835 * fncAcc)*100, 2)
	} Else {
		totAcc	:= pAcc + pBuff
		AccMod	:= (1.84 + 0.07 * LvlDiff) * mEva
		maxAcc	:= Ceil((1 + 1) * AccMod)
		pctAcc	:= Ceil((1 + sPct / 100) * AccMod)
		
		hitRate	:= RegExReplace(100 * (totAcc / (AccMod) - 1), "(\.\d{2})\d*","$1")
	}
	
	If (hitRate < 0)
		hitRate := 0
	Else If (hitRate >= 100)
		hitRate := 100

	GuiControl,, totAcc, %totAcc%
	GuiControl,, hitRate, %hitRate%`%
	GuiControl,, maxAcc, %maxAcc%
	GuiControl,, pctAcc, %pctAcc%
Return


ReadINI:
	IniRead, pType,	%A_ScriptFullPath%.ini, Settings, PlayerType,	
	IniRead, pLvl,	%A_ScriptFullPath%.ini, Settings, PlayerLvl,	50
	IniRead, pAcc,	%A_ScriptFullPath%.ini, Settings, PlayerAcc,	147
	IniRead, pInt,	%A_ScriptFullPath%.ini, Settings, PlayerInt,	300
	IniRead, pLuk,	%A_ScriptFullPath%.ini, Settings, PlayerLuk,	10
	IniRead, mLvl,	%A_ScriptFullPath%.ini, Settings, MonsterLvl,	76
	IniRead, mEva,	%A_ScriptFullPath%.ini, Settings, MonsterEva,	40
	IniRead, sPos,	%A_ScriptFullPath%.ini, Settings, HitGoal,	90
	sPct := sPos
Return

Reset:
	Gosub, ReadINI
	GuiControl, Choose, pType, 2
	GuiControl,, pLvl, %pLvl%
	GuiControl,, pAcc, %pAcc%
	GuiControl,, pInt, %pInt%
	GuiControl,, pLuk, %pLuk%
	GuiControl,, mLvl, %mLvl%
	GuiControl,, mEva, %mEva%
	GuiControl,, totAcc
	GuiControl,, hitRate
	GuiControl,, maxAcc
	GuiControl,, pctAcc
	GuiControl,, sPct, %sPos%
	GuiControl, Text, SliderText, Acc. for %sPos%`% Hit:
Return

Clear:
	GuiControl, Choose, pType, 0
	GuiControl,, pLvl
	GuiControl,, pAcc
	GuiControl,, pInt
	GuiControl,, pLuk
	GuiControl,, mLvl
	GuiControl,, mEva
	GuiControl,, totAcc
	GuiControl,, hitRate
	GuiControl,, maxAcc
	GuiControl,, pctAcc
	GuiControl,, sPct, %sPos%
	GuiControl, Text, SliderText, Acc. for %sPos%`% Hit:
Return


;Row Height = (n * 19) + 6
;Edit Height = (n * 26) + 18
editHeight(n) {
	Return n * 26 + 18
}
