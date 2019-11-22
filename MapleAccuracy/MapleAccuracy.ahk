#SingleInstance, Force
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn	; Enable warnings to assist with detecting common errors.
SendMode Input	; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%	; Ensures a consistent starting directory.
FileEncoding, UTF-8


If !FileExist(A_ScriptFullPath ".csv")
	URLDownloadToFile, https://raw.githubusercontent.com/twiz-ahk/ahk-scripts/master/MapleAccuracy/MapleAccuracy.csv , %A_ScriptFullPath%.csv


edtW	:= 100
guiW	:= 110 + edtW
edtX	:= guiW - edtW - 9
nBtn	:= 3
btnW	:= 50
btnH	:= 23 ; Default = 23
btnG	:= (guiW - (btnW * nBtn)) / (nBtn + 1)

_MonArray := []
Gosub ReadINI
Gosub ReadDB

BuffList = 
(
|
   -5  Cider|
    5  Sniper Potion|
  10  Sniper Pill/Candy Basket|
  20  Bless|
  30  Candy|
  30  Banana Graham Pie|
  30  Chocolate Cream Cupcake|
  30  Gelt Chocolate|
  40  Amorian Basket|
  50  Heartstopper|
  50  Maple Syrup|
100  Maple Pop|
100  GM Bless|
)

guiH1 := editHeight(4)
Gui, Add, GroupBox, Section w%guiW% h%guiH1%, Character Stats
Gui, Add, Text,	xs+10 ys+19, Character Type:
Gui, Add, DDL,	xs+%edtX% yp-3 w%edtW% vpType gGuiUpdate, Magician|Non-Magician||
Gui, Add, Text, xs+10 y+8, Character Level:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vpLvl gCalculate, %pLvl%
Gui, Add, Text, xs+10 y+8 vText1, Character ####:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vpInt gCalculate, %pInt%
Gui, Add, Edit, xs+%edtX% yp w%edtW% vpAcc gCalculate, %pAcc%
Gui, Add, Text, xs+10 y+8 vText2, Character ####:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vpLuk gCalculate, %pLuk%
Gui, Add, DDL, xs+%edtX% yp w%edtW% hwndBuffID vpBuffName gSetBuff, %BuffList%
SendMessage, 0x0160, 175, 0, , ahk_id %BuffID%

guiH2 := editHeight(3)
Gui, Add, GroupBox, Section xs w%guiW% h%guiH2%, Monster Stats
Gui, Add, ComboBox, xs+10 ys+19 r19 w191 hwndMonID vmName gSetMon, %_MonList%
Gui, Add, Text, xs+10 y+8, Monster Level:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vmLvl gCalculate, %mLvl%
Gui, Add, Text, xs+10 y+8, Monster Evade:
Gui, Add, Edit, xs+%edtX% yp-3 w%edtW% vmEva gCalculate, %mEva%

guiH3 := editHeight(5)
If %SView% {
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

If %SView% {
	bYPos := (guiH1 + guiH2) - Floor(guiH3 + btnH / 2)	; Split view
} Else {
	bYPos := 12
}
Gui, Add, Button, xs+%btnG% y+%bYPos% w%btnW% h%btnH% +Default gWriteINI, Save
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
		GuiControl, Hide, pAcc
		GuiControl, Hide, pBuffName
		GuiControl, Show, pInt
		GuiControl, Show, pLuk
	} Else {
		GuiControl, Text, Text1, Character Acc:
		GuiControl, Text, Text2, Accuracy Buff:
		GuiControl, Hide, pInt
		GuiControl, Hide, pLuk
		GuiControl, Show, pAcc
		GuiControl, Show, pBuffName
	}
AccSlider:
	Gui, Submit, NoHide
	GuiControl, Text, SliderText, Acc. for %sPct%`% Hit:
	Gosub, Calculate
Return

SetBuff:
	Gui, Submit, NoHide
	If (pBuffName = "")
		pBuff := 0
	Else
		pBuff := RegExReplace(pBuffName, "\s*(.?\d+).*", "$1")
	Gosub, Calculate
Return

SetMon:
	CbAutoComplete()
	GuiControl, +AltSubmit, mName
	Gui, Submit, NoHide
	_MonIndex := mName - 1
	GuiControl, -AltSubmit, mName
	GuiControl,, mLvl, % _MonArray[_MonIndex, 3]
	GuiControl,, mEva, % _MonArray[_MonIndex, 4]
	Gosub, Calculate
Return

Calculate:
	Gui, Submit, NoHide
	LvlDiff := mLvl - pLvl
	If (LvlDiff < 0)
		LvlDiff := 0

	If (pType = "Magician") {
		totAcc	:= Floor(pInt / 10) + Floor(pLuk / 10)
		maxAcc	:= Ceil((mEva + 1) * (1 + 0.04 * LvlDiff))
		pctAcc	:= "Work in progress"
		minAcc	:= Ceil(0.41 * maxAcc)
		
		fncAcc	:= (totAcc - minAcc + 1) / (maxAcc - minAcc + 1)
		hitRate	:= Round((-0.7011618132 * (fncAcc**2) + 1.702139835 * fncAcc)*100, 2)
	} Else {
		totAcc	:= pAcc + pBuff
		AccMod	:= (1.84 + 0.07 * LvlDiff) * mEva
		If (AccMod < 1)
			AccMod := 1
		maxAcc	:= Ceil((1 + 1) * AccMod)
		pctAcc	:= Ceil((1 + sPct / 100) * AccMod)
		
		hitRate	:= RegExReplace(100 * (totAcc / (AccMod) - 1), "(\.\d{2})\d*","$1")
	}
	
	If (hitRate < 0)
		hitRate := 0
	Else If (hitRate > 100)
		hitRate := 100

	GuiControl,, totAcc, %totAcc%
	GuiControl,, hitRate, %hitRate%`%
	GuiControl,, maxAcc, %maxAcc%
	GuiControl,, pctAcc, %pctAcc%
Return


ReadINI:
	IniRead, pType,	%A_ScriptFullPath%.ini, Settings, PlayerType
	IniRead, pLvl,	%A_ScriptFullPath%.ini, Settings, PlayerLvl, 1
	IniRead, pAcc,	%A_ScriptFullPath%.ini, Settings, PlayerAcc, 1
	IniRead, pInt,	%A_ScriptFullPath%.ini, Settings, PlayerInt, 4
	IniRead, pLuk,	%A_ScriptFullPath%.ini, Settings, PlayerLuk, 4
	IniRead, mLvl,	%A_ScriptFullPath%.ini, Settings, MonsterLvl, 1
	IniRead, mEva,	%A_ScriptFullPath%.ini, Settings, MonsterEva, 1
	IniRead, sPos,	%A_ScriptFullPath%.ini, Settings, HitGoal, 90
	IniRead, SView,	%A_ScriptFullPath%.ini, Settings, SplitView, 0
	sPct := sPos
	pBuff := 0
Return

WriteINI:
	IniWrite, %pType%,	%A_ScriptFullPath%.ini, Settings, PlayerType
	IniWrite, %pLvl%,	%A_ScriptFullPath%.ini, Settings, PlayerLvl
	IniWrite, %pAcc%,	%A_ScriptFullPath%.ini, Settings, PlayerAcc
	IniWrite, %pInt%,	%A_ScriptFullPath%.ini, Settings, PlayerInt
	IniWrite, %pLuk%,	%A_ScriptFullPath%.ini, Settings, PlayerLuk
	IniWrite, %mLvl%,	%A_ScriptFullPath%.ini, Settings, MonsterLvl
	IniWrite, %mEva%,	%A_ScriptFullPath%.ini, Settings, MonsterEva
	IniWrite, %sPos%,	%A_ScriptFullPath%.ini, Settings, HitGoal
	IniWrite, %SView%,	%A_ScriptFullPath%.ini, Settings, SplitView
Return

ReadDB:
	n := 0
	_MonList := ""
	FileRead, _MonDB, MapleAccuracy.csv
	Loop, Parse, _MonDB, `n
	{
		n += 1
		Loop, Parse, A_LoopField, CSV
		{
			If (A_Index <= 4)
			_MonArray[n,A_Index] := A_LoopField
		}
		_MonList .= "|" _MonArray[n,2]
	}
	_MonDB := ""
Return

Reset:
	Gosub, ReadINI
	GuiControl, Choose, pType, %pType%
	GuiControl,, pLvl, %pLvl%
	GuiControl,, pAcc, %pAcc%
	GuiControl,, pInt, %pInt%
	GuiControl,, pLuk, %pLuk%
	GuiControl,, mLvl, %mLvl%
	GuiControl,, mEva, %mEva%
	Gosub, CommonClear
	Gosub, Calculate
Return

Clear:
	GuiControl, Choose, pType, 0
	GuiControl,, pLvl
	GuiControl,, pAcc
	GuiControl,, pInt
	GuiControl,, pLuk
	GuiControl,, mLvl
	GuiControl,, mEva
	Gosub, CommonClear
Return

CommonClear:
	GuiControl, Choose, pBuffName, 0
	GuiControl, Choose, mName, 0
	GuiControl,, pBuff
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


;=======================================================================================
;
; Function:      CbAutoComplete
; Description:   Auto-completes typed values in a ComboBox.
;
; Author:        Pulover [Rodolfo U. Batista]
; Link:          https://github.com/Pulover/CbAutoComplete
; Usage:         Call the function from the Combobox's gLabel.
;
;=======================================================================================
CbAutoComplete()
{	; CB_GETEDITSEL = 0x0140, CB_SETEDITSEL = 0x0142
	If ((GetKeyState("Delete", "P")) || (GetKeyState("Backspace", "P")))
		return
	GuiControlGet, lHwnd, Hwnd, %A_GuiControl%
	SendMessage, 0x0140, 0, 0,, ahk_id %lHwnd%
	MakeShort(ErrorLevel, Start, End)
	GuiControlGet, CurContent,, %lHwnd%
	GuiControl, ChooseString, %A_GuiControl%, %CurContent%
	If (ErrorLevel)
	{
		ControlSetText,, %CurContent%, ahk_id %lHwnd%
		PostMessage, 0x0142, 0, MakeLong(Start, End),, ahk_id %lHwnd%
		return
	}
	GuiControlGet, CurContent,, %lHwnd%
	PostMessage, 0x0142, 0, MakeLong(Start, StrLen(CurContent)),, ahk_id %lHwnd%
}

MakeLong(LoWord, HiWord)
{
	return (HiWord << 16) | (LoWord & 0xffff)
}

MakeShort(Long, ByRef LoWord, ByRef HiWord)
{
	LoWord := Long & 0xffff
,   HiWord := Long >> 16
}
