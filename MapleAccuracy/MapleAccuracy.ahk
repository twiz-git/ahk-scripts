#SingleInstance, Force
#NoEnv	; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn	; Enable warnings to assist with detecting common errors.
SendMode Input	; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%	; Ensures a consistent starting directory.
FileEncoding, UTF-8
ScriptName := StrReplace(A_ScriptFullPath, ".ahk")

If !FileExist(ScriptName ".csv")
URLDownloadToFile, https://raw.githubusercontent.com/twiz-ahk/ahk-scripts/master/MapleAccuracy/MapleAccuracy.csv , %ScriptName%.csv

edtW	:= 100
guiW	:= 110 + edtW
edtX	:= guiW - edtW - 9
nBtn	:= 3
btnW	:= 50
btnH	:= 23 ; Default = 23
btnG	:= (guiW - btnW * nBtn) / (nBtn + 1)
SldW	:= guiW - 8

_MonArray := []
Gosub, ReadINI
Gosub, ReadDB

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
Gui, Add, GroupBox,						w%guiW%		h%guiH1%						Section		, Character Stats
Gui, Add, Text,		xs+10		ys+19															, Character Type:
Gui, Add, DDL,		xs+%edtX%	yp-3	w%edtW%				vpType		gGuiUpdate				, Magician|Non-Magician|
Gui, Add, Text,		xs+10		y+8																, Character Level:
Gui, Add, Edit,		xs+%edtX%	yp-3	w%edtW%				vpLvl		gCalculate	Number		, %pLvl%
Gui, Add, Text,		xs+10		y+8							vText1								, Character ####:
Gui, Add, Edit,		xs+%edtX%	yp-3	w%edtW%				vpInt		gCalculate	Number		, %pInt%
Gui, Add, Edit,		xs+%edtX%	yp		w%edtW%				vpAcc		gCalculate	Number		, %pAcc%
Gui, Add, Text,		xs+10		y+8							vText2								, Character ####:
Gui, Add, Edit,		xs+%edtX%	yp-3	w%edtW%				vpLuk		gCalculate	Number		, %pLuk%
Gui, Add, DDL,		xs+%edtX%	yp		w%edtW%				vpBuffName	gSetBuff	hwndBuffID	, %BuffList%
SendMessage, 0x0160, 175, 0, , ahk_id %BuffID%

guiH2 := editHeight(3)
Gui, Add, GroupBox, xs					w%guiW%		h%guiH2%						Section		, Monster Stats
Gui, Add, ComboBox,	xs+10		ys+16	w191		r19		vmName		gSetMon		hwndMonID	, %_MonList%
Gui, Add, Text,		xs+10		y+8																, Monster Level:
Gui, Add, Edit,		xs+%edtX%	yp-3	w%edtW%				vmLvl		gCalculate	Number		, %mLvl%
Gui, Add, Text,		xs+10		y+8																, Monster Evade:
Gui, Add, Edit,		xs+%edtX%	yp-3	w%edtW%				vmEva		gCalculate	Number		, %mEva%

guiH3 := editHeight(5)
If %SView% {	; Split view
	bYPos	:= (guiH1 + guiH2) - Floor(guiH3 + btnH / 2)
	SectW	:= guiW + 8
	SectY	:= "y6"
} Else {		; Tall view
	bYPos	:= 12
	SectY	:= ""
}
Gui, Add, GroupBox,	xs+%SectW%	%SectY%	w%guiW%		h%guiH3%						Section		, Calculations
Gui, Add, Text,		xs+10		ys+19															, Total Accuracy:
Gui, Add, Edit,		xs+%edtX% 	yp-3 	w%edtW% 			vtotAcc					+ReadOnly
Gui, Add, Text,		xs+10 		y+8																, Your Hit Rate:
Gui, Add, Edit,		xs+%edtX%	yp-3	w%edtW%				vhitRate				+ReadOnly
Gui, Add, Text,		xs+10		y+8																, Acc. for 100`% Hit:
Gui, Add, Edit,		xs+%edtX%	yp-3	w%edtW%				vmaxAcc					+ReadOnly

Gui, Add, Text,		xs+10		y+8							vSliderText							, Acc. for ###`% Hit:
Gui, Add, Edit,		xs+%edtX% 	yp-3	w%edtW%				vpctAcc					+ReadOnly
Gui, Add, Slider,	xs+4		y+5		w%SldW%		h20		vsPct		gAccSlider	AltSubmit +TickInterval10 +0x400, %sPct%

If %SView% {
	
} Else {
	
}
Gui, Add, Button,	xs+%btnG%	y+%bYPos%	w%btnW%		h%btnH%			gWriteINI	+Default	, Save
Gui, Add, Button,	x+%btnG%				w%btnW%						gReset					, Reset
Gui, Add, Button,	x+%btnG%				w%btnW%						gClear					, Clear


GuiControl, ChooseString, pType, %pType%
GuiControl, ChooseString, mName, %mName%
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
		pBuff := RegExReplace(pBuffName, "\s*(\-?\d+).*", "$1")
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
Return

Calculate:
	Gui, Submit, NoHide
	LvlDiff := mLvl - pLvl
	If (LvlDiff < 0)
		LvlDiff := 0

	If (pType = "Magician") {
		totAcc	:= Floor(pInt / 10) + Floor(pLuk / 10)
		maxAcc	:= Floor((mEva + 1) * (1 + 0.04 * LvlDiff))
		minAcc	:= Floor(0.41 * maxAcc)
		pctAcc	:= Ceil((maxAcc-1) * sPct / 100)

		If (totAcc < maxAcc) {
			fncAcc	:= (totAcc - minAcc + 1) / (maxAcc - minAcc + 1)
			hitRate	:= Round((-0.7011618132 * fncAcc**2 + 1.702139835 * fncAcc) * 100, 2)
		} Else {
			hitRate := 100
		}
	} Else {
		totAcc	:= pAcc + pBuff
		AccMod	:= (1.84 + 0.07 * LvlDiff) * mEva
		If (AccMod < 1)
			AccMod := 1
		maxAcc	:= Ceil((1 + 1) * AccMod)
		pctAcc	:= Ceil((1 + sPct / 100) * AccMod)

		hitRate	:= Round(100 * (totAcc / AccMod - 1), 2)
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
	Gui, Submit, NoHide
	IniRead, pType,		%ScriptName%.ini, Player, PlayerType
	IniRead, pLvl,		%ScriptName%.ini, Player, PlayerLvl, 1
	IniRead, pAcc,		%ScriptName%.ini, Player, PlayerAcc, 1
	IniRead, pInt,		%ScriptName%.ini, Player, PlayerInt, 4
	IniRead, pLuk,		%ScriptName%.ini, Player, PlayerLuk, 4
	IniRead, mName,		%ScriptName%.ini, Monster, MonsterName
	IniRead, mLvl,		%ScriptName%.ini, Monster, MonsterLvl, 1
	IniRead, mEva,		%ScriptName%.ini, Monster, MonsterEva, 1
	IniRead, sPos,		%ScriptName%.ini, Monster, HitGoal, 90
	IniRead, SView,		%ScriptName%.ini, Settings, SplitView, 0
	sPct := sPos
	pBuff := 0
Return

WriteINI:
	IniWrite, %pType%,	%ScriptName%.ini, Player, PlayerType
	IniWrite, %pLvl%,	%ScriptName%.ini, Player, PlayerLvl
	IniWrite, %pAcc%,	%ScriptName%.ini, Player, PlayerAcc
	IniWrite, %pInt%,	%ScriptName%.ini, Player, PlayerInt
	IniWrite, %pLuk%,	%ScriptName%.ini, Player, PlayerLuk
	IniWrite, %mName%,	%ScriptName%.ini, Monster, MonsterName
	IniWrite, %mLvl%,	%ScriptName%.ini, Monster, MonsterLvl
	IniWrite, %mEva%,	%ScriptName%.ini, Monster, MonsterEva
	IniWrite, %sPct%,	%ScriptName%.ini, Monster, HitGoal
	IniWrite, %SView%,	%ScriptName%.ini, Settings, SplitView
Return

ReadDB:
	n := 0
	_MonList := ""
	FileRead, _MonDB, %ScriptName%.csv
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
	GuiControl, Choose, mName, %mName%
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
	GuiControl, Choose, mName, 0
	GuiControl,, mLvl
	GuiControl,, mEva
	Gosub, CommonClear
Return

CommonClear:
	GuiControl, Choose, pBuffName, 0
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
