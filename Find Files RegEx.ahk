#NoEnv
#SingleInstance, Force
SplitPath, A_WinDir,,,,, SysDrive
SysDrive .= "\"
SplitPath, A_ScriptFullPath,, Path,, File
iniFile := Path "\" File ".ini"

ToDoList =
(
Wish list:
• Commandline version
• "Basic" (non-RegEx) search history
• Search within results
• Rewrite/Cleanup/Make functions
• Total size of selected files
• Selected Properties
)

; Declare variables as Arrays (initialize to 10 empty strings)
PathArray := ["","","","","","","","","",""]
RegExArray := ["","","","","","","","","",""]

Gosub ReadHistory
Menu, Tray, Icon, %A_WinDir%\system32\SHELL32.dll, 210
  hIcon := DllCall( "LoadImage", UInt,0, Str, Ico, UInt,1, UInt,0, UInt,0, UInt,0x10 )
  ;SendMessage, 0x80, 0, hIcon ; One affects Title bar and
  ;SendMessage, 0x80, 1, hIcon ; the other the ALT+TAB menu
Gui, Font, s10
Menu, FileMenu, Add, E&xit, FileClose
Menu, MenuBar, Add, &File, :FileMenu
Menu, OptionsMenu, Add, &Close to Tray, CloseToTray
Menu, OptionsMenu, Add, Open without &Asking, ToggleAsk
Menu, OptionsMenu, Add, Set Output Directory, SetOutput
Menu, MenuBar, Add, &Options, :OptionsMenu
Menu, HelpMenu, Add, &Todo List, Todo
Menu, HelpMenu, Add, &About, About
Menu, HelpMenu, Add
Menu, HelpMenu, Add, &Edit .INI File, EditIni
Menu, MenuBar, Add, &Help, :HelpMenu
Menu, Tray, NoStandard
Menu, Tray, Add, Restore Window, GuiShow
Menu, Tray, Default, Restore Window
Menu, Tray, Click, 1
Menu, Tray, Standard
Gui +DelimiterTab ;Delimiter is `t
Gui, Menu, MenuBar
Gui, Add, Button,   x9    y8  w59  h26 gBrowse, &Browse
Gui, Add, ComboBox, x+5   y9  w617 vPathText, %SysDrive%`t`t%PathHistory%
Gui, Add, Text,     x9    y42, &Filename:
Gui, Add, ComboBox, x+5   y38 w455 vFileText
Gui, Add, Checkbox, x+5   y42 vSRegEx gSRegEx checked, &RegEx
Gui, Add, Checkbox, x+0   y42 vCase gCase, &Match CaSe
Gui, Add, Text,     xp+10 y42 vExtText, Ext:
Gui, Add, Edit,     x+5   y38 w55  h22 vFileExt, *
Gui, Add, Button,   x9    y66 w75 gClear, &Clear list
Gui, Add, Button,   x+5   yp  w75 gExport, &Export list
Gui, Add, Button,   x506  yp  w75 gNewTest DISABLED, NewTest
Gui, Add, Button,   x+5   yp  w75 gRefine DISABLED, Refine
Gui, Add, Button,   x+5   yp  w75 gSearchButton +Default, &Search
Gui, Font, s8
Gui, Add, ListView, x10   y98 w680 h269 gClicked vList +AltSubmit, Path `t File `t Size (KB)
Gui, Add, Statusbar, h25
Gui, +Resize +MinSize425x175
Gui, Show, w750 h450
Gui, +LastFound
Gui1 := WinExist()

iniRead, vTrayClose, %iniFile%, Settings, CloseToTray, 1
IfEqual, vTrayClose, 1, Gosub, CloseToTray2
iniRead, vSkipAskOpen, %iniFile%, Settings, SkipAskOpen, 0
IfEqual, vSkipAskOpen, 1, Gosub, ToggleAsk2
iniRead, OutputDir, %iniFile%, Settings, OutputDir, %A_Desktop%

SRegEx:
  GuiControlGet, DoRegEx,, SRegEx
  If (DoRegEx = 1)
  {
    GuiControl, Disable, FileExt
    GuiControl, Hide, FileExt
    GuiControl, Hide, ExtText
    GuiControl, Show, Case
    GuiControl,, FileText, `t.*`t`t%RegExHistory%
  } Else {
    GuiControl, Enable, FileExt
    GuiControl, Show, FileExt
    GuiControl, Show, ExtText
    GuiControl, Hide, Case
    GuiControl,, FileText, `t*`t`t
  }
Case:
  GuiControlGet, MatchCase,, Case
  vCase := (MatchCase ? "" : "(?i)")
Return

SetOutput:
  Gui +OwnDialogs
  FileSelectFolder, OutputDir, ::{20d04fe0-3aea-1069-a2d8-08002b30309d} *%OutputDir%, 3
  If (OutputDir = "")
    iniRead, OutputDir, %iniFile%, Settings, OutputDir, %A_Desktop%
  Else
    iniWrite, %OutputDir%, %iniFile%, Settings, OutputDir
Return

Browse:
  Gui +OwnDialogs
  FileSelectFolder, vPath, ::{20d04fe0-3aea-1069-a2d8-08002b30309d} *%vPath%, 0
  vPath := (vPath = "" ? SysDrive : vPath)
  GuiControl, Text, PathText, %vPath%
Return

Clear:
  Searching =
  LV_Delete()
  SB_SetText("")
  GuiControl,, &Stop, &Search
  GuiControl, Disable, Refine
Return

Export:
  xFiles := LV_GetCount()
  Loop, %xFiles%
  {
    LV_GetText(CurFolder, A_Index, 1)
    LV_GetText(CurFile, A_Index, 2)
    Output .= CurFolder CurFile "`n"
  }
  If (Output = "")
    MsgBox Nothing to save.
  Else
  {
    OutputFile = Results %A_YYYY%-%A_MM%-%A_DD%_%A_Hour%%A_Min%.txt
    FileAppend, %Output%, %OutputDir%\%OutputFile%
    MsgBox % (ErrorLevel = 0 ? "List exported to" : "Error writing") " file:`n%OutputDir%\%OutputFile%"
  }
Return

Refine:
  MsgBox Under Construction
Return

SearchButton:
  If Searching
    Searching =
  Else
  {
    Searching = 1
    SetTimer, Search, -1
  }
  ;GuiControl, Enable, Refine
Return

Search:
  GuiControlGet, vPath,, PathText
  GuiControlGet, vFile,, FileText
  GuiControlGet, vExt,, FileExt
  GoSub UpdateHistory
  If (vPath = "")
  {
    vPath = %SysDrive%
    GuiControl,, PathText, %vPath%
  }
  If (vFile = "")
  {
    Gosub SRegEx
    Goto Search
  }
  If (vExt = "")
    vExt = *
  LV_Delete()
  GuiControl,, &Search, &Stop
  ;GuiControl, -Redraw, List
  SB_SetText(" Searching...")
  If !(SubStr(vPath, 0, 1)=="\")
    vPath .= "\"
  If (DoRegEx = 1)
  {
    Loop, %vPath%*,0,1
    {
      If RegExMatch(A_LoopFileName, vCase "^" vFile "$")
        Lv_Add("", A_LoopFileDir "\", A_LoopFileName, A_LoopFileSizeKB)
      If !Searching
        Break
    }
  } Else {
    Loop, %vPath%%vFile%.%vExt%,0,1
    {
      Lv_Add("", A_LoopFileDir "\", A_LoopFileName, A_LoopFileSizeKB)
      If !Searching
        Break
    }
  }
  ;GuiControl, +Redraw, List
  Gosub UpdateSB
  Searching =
  GuiControl,, &Stop, &Search
Return


; List View
Clicked:
  LV_GetText(SelFolder, A_EventInfo, 1)
  LV_GetText(SelFile, A_EventInfo, 2)
  If A_GuiEvent = Normal
    Gosub UpdateSB
  If A_GuiEvent = DoubleClick
  {
    RowNum = %A_EventInfo%
    Gui, 2:+owner1
    Gui, 2:Add, Text,   x10 y10, Path and Original Name:
    Gui, 2:Add, Edit,   x10 y+5  w415 r1 Disabled, %SelFolder%
    Gui, 2:Add, Edit,   x10 y+0  w415 r1 vOldName Disabled, %SelFile%
    Gui, 2:Add, Text,   x10 y+5, New Name:
    Gui, 2:Add, Edit,   x10 y+5  w415 r1 vNewName, %SelFile%
    ;Gui, 2:Add, Button, x10 y+20 w75, Close
    Gui, 2:Add, Button, x10 y+20 w75, Rename
    Gui, 2:Add, Button, x+10     w75, Recycle
    Gui, 2:Add, Button, x+10     w75, Properties
    Gui, 2:Add, Button, x+10     w75, Open
    Gui, 2:Add, Button, x+10     w75, Folder
    Gui, 2:Show, w435 h175, File Options
    Gui, 1:+Disabled
  }
Return
UpdateSB:
/*
  nFiles := LV_GetCount("s")
  Loop, %nFiles% {
    ToolTip % A_Index
  }
*/
  SB_SetText(" " LV_GetCount() " files found`t" LV_GetCount("s") " file" (LV_GetCount("s") > 1 ? "s" : "" ) " selected`t <FILESIZEHERE> KB      ")
Return

NewTest:
Return

; GUI Resize
GuiSize:
  ;WinGetPos,,, vW, vH, A
  GuiGetSize(vW, vH, 1)
  Col1 := Floor((vW-100)*0.5)
  Col2 := Floor((vW-100)*0.5)
  LV_ModifyCol(1,Col1)
  LV_ModifyCol(2,Col2)
  LV_ModifyCol(3, "59 Integer Desc")
  GuiControl, Move, List,     % "w" vW-20 "h" vH-131
  GuiControl, Move, PathText, % "w" vW-83
  GuiControl, Move, FileText, % "w" vW-248
  GuiControl, Move, SRegEx,   % "x" vW-167
  GuiControl, Move, Case,     % "x" vW-103
  GuiControl, Move, Ext:,     % "x" vW-91
  GuiControl, Move, FileExt,  % "x" vW-65
  GuiControl, Move, NewTest,  % "x" vW-244
  GuiControl, Move, Refine,   % "x" vW-164
  GuiControl, Move, &Search,  % "x" vW-84
  GuiControl, Move, &Stop,    % "x" vW-84
  SetTimer, DoRedraw, -100
Return

DoRedraw:
  WinSet, Redraw,, A
Return


; GUI Settings
GuiShow:
  Gui, Show
  Return
GuiClose:
  If (vTrayClose = 1)
  {
    Gui, Hide
    Gosub WriteHistory
  } else {
  FileClose:
    Gosub WriteHistory
    ExitApp
  }
  Return

CloseToTray:
  iniWrite, %vTrayClose%, %iniFile%, Settings, CloseToTray
  CloseToTray2:
    Menu, OptionsMenu, ToggleCheck, &Close to Tray
    vTrayClose := IsMenuItemChecked( 1, 0, Gui1 )
  Return
ToggleAsk: ;writes the value on startup... I want to avoid this
  iniWrite, %vSkipAskOpen%, %iniFile%, Settings, SkipAskOpen
  ToggleAsk2:
    Menu, OptionsMenu, ToggleCheck, Open without &Asking
    vSkipAskOpen := IsMenuItemChecked( 1, 1, Gui1 )
  Return
Todo:
  Gui +OwnDialogs
  MsgBox,, Todo List, %ToDoList%
  Return
About:
  Gui +OwnDialogs
  MsgBox,, About Find Files RegEx.ahk, Blah Blah Blah.
  Return
EditIni:
  Run %iniFile%
  Return


; History
ReadHistory: ;Rework into a function?
  For index, value in PathArray {
    iniRead, PathHistory%index%, %iniFile%, PathHistory, %index%, %A_Space%
    PathArray[Index] := PathHistory%Index%
    PathHistory .= PathArray[Index] "`t"
  }
  PathHistory  := RegExReplace(PathHistory, "\t*$")

  For index, value in RegExArray {
    iniRead, RegExHistory%index%, %iniFile%, RegExHistory, %index%, %A_Space%
    RegExArray[index] := RegExHistory%index%
    RegExHistory .= RegExArray[index] "`t"
  }
  RegExHistory := RegExReplace(RegExHistory, "\t*$")
Return

UpdateHistory: ;Rework into a function?
  If !(vPath = SysDrive) ;Skip adding system root
    Assign(PathArray, vPath)
  PathHistory := "`t"
  For index, value in PathArray {
    PathHistory .= value "`t"
  }
  PathHistory := RegExReplace(PathHistory, "\t*$")
  GuiControl,, PathText, `t%SysDrive%%PathHistory%
  GuiControl, ChooseString, PathText, %vPath%

  If !(vFile = ".*") ;Skip adding ".*"
    Assign(RegExArray, vFile)  
  RegExHistory := "`t"
  For index, value in RegExArray {
    RegExHistory .= value "`t"
  }
  RegExHistory := RegExReplace(RegExHistory, "\t*$")
  GuiControl,, FileText, `t.*%RegExHistory%
  GuiControl, ChooseString, FileText, %vFile%
Return

WriteHistory: ;Rework into a function?
  For index, value in PathArray
    iniWrite, %value%, %iniFile%, PathHistory, %index%
  
  For index, value in RegExArray
    iniWrite, %value%, %iniFile%, RegExHistory, %index%
Return


; Popup Menu
2ButtonRename:
  GuiControlGet, NewName,, NewName
  Gui, +OwnDialogs
  MsgBox, 4, Rename?,  %SelFolder%`n%SelFile%`n%NewName%
    IfMsgBox, Yes
    {
      FileMove, %SelFolder%%SelFile%, %SelFolder%%NewName%
      Gui, 1:Default    
      LV_Modify(RowNum,"Col2",NewName)
    }
  Return
2ButtonRecycle:
  Gui, +OwnDialogs
    MsgBox, 4, Recycle?, Are you sure you wish to send this file to the Recycle Bin?`n%SelFolder%%SelFile%
    IfMsgBox, Yes
    {
      FileRecycle, %SelFolder%%SelFile%
      If !(ErrorLevel = 0)
        MsgBox, An error occured. Could not recycle the file:`n%SelFolder%%SelFile%
      Else {
        Gui, 1:Default    
        LV_Delete(RowNum)
      }
    }
  Goto 2GuiClose
2ButtonOpen:
  Gui, +OWnDialogs
  If !(vSkipAskOpen = 1) {
    MsgBox, 4, Open?, Are you sure you wish to run this file?`t %SelFolder%%SelFile%
    IfMsgBox, Yes
      DoOpen = 1
  }
  If (vSkipAskOpen = 1) OR (DoOpen = 1)
    Run, %SelFolder%%SelFile%
  DoOpen = 0
  Goto 2GuiClose
2ButtonProperties:  
  Run, properties %SelFolder%%SelFile%
  Return
2ButtonFolder:
  Run, explore %SelFolder%
  Goto 2GuiClose
2GuiClose:
2GuiEscape:
2ButtonClose:
  Gui, 1:-Disabled
  Gui, 2:Destroy
Return


; Functions
IsMenuItemChecked( MenuPos, SubMenuPos, hWnd ) { ; By Obi / Lexikos
;Original version: www.autohotkey.com/forum/viewtopic.php?p=203606#203606
 hMenu :=DllCall("GetMenu", UInt,hWnd )
 hSubMenu := DllCall("GetSubMenu", UInt,hMenu, Int,MenuPos )
 VarSetCapacity(mii, 48, 0), NumPut(48, mii, 0), NumPut(1, mii, 4)
 DllCall( "GetMenuItemInfo", UInt,hSubMenu, UInt,SubMenuPos, Int, 1, UInt,&mii )
Return ( NumGet(mii, 12) & 0x8 ) ? 1 : 0
}

GuiGetSize( ByRef W, ByRef H, GuiID=1 ) {
   Gui %GuiID%:+LastFound
   VarSetCapacity( rect, 16, 0 )
   DllCall("GetClientRect", uint, MyGuiHWND := WinExist(), uint, &rect )
   W := NumGet( rect, 8, "int" )
   H := NumGet( rect, 12, "int" )
}

Assign(ByRef varName, newVal){ ;thanks Elesar
  for index, value in varName
  {
    if (value == newVal)
      varName.Remove(index)
  }
  varName.Insert(1, newVal)
  varName.Remove(11)
}