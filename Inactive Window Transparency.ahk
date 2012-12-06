#NoEnv
#SingleInstance, Force
;DetectHiddenWindows, On
OnExit, Cleanup

;Default Variables
Def_Time := 150
Def_APct := 85
Def_IPct := 30
Blank := A_Space

Menu, Tray, NoStandard
Menu, Tray, Add, Edit Settings File, EditSettings
Menu, Tray, Add, Write Settings File, WriteSettings
Menu, Tray, Add
Menu, Tray, Add, Pause Script, PauseScript
Menu, Tray, Add, Reload Script, ReloadScript
Menu, Tray, Add, Exit, ExitScript
OnMessage(0x404, "AHK_NOTIFYICON")

SplitPath, A_ScriptFullPath,, Path,, File
SetWorkingDir, %Path%
iniFile := File ".ini"

iniRead, Interval, %iniFile%, Settings, Interval, %Def_Time%
iniRead, ini_APct, %iniFile%, Settings, Active_Trans, %Def_APct%
iniRead, ini_IPct, %iniFile%, Settings, Transparency, %Def_IPct%
iniRead, iniTitle, %iniFile%, Settings, Ignore_Title, %Blank%
iniRead, iniClass, %iniFile%, Settings, Ignore_Class, %Blank%
iniRead, Debug,    %iniFile%, Settings, Debug, 0
ActiveTrans   := Round(255 * (ini_APct / 100))
InactiveTrans := Round(255 * (ini_IPct / 100))
StringReplace, iniTitle, iniTitle, `,%A_Space%, `,, All
StringReplace, iniClass, iniClass, `,%A_Space%, `,, All
TitleList := "," iniTitle
ClassList := "Button,Desktop User Picture,SysDragImage,Progman,Shell_TrayWnd,MsCommunicatorToastPopup,NUIDialog,icoTrilly," iniClass
;Ghost
;DV2ControlHost,SysShadow,GestureFeedbackAnimationWindow

SetTimer, TransWindows, %Interval%
Return


TransWindows:
    WinGet, IDList, List
    Loop, %IDList%
    {
        WinID := IDList%A_Index%
        WinGetTitle,       Win_Title, ahk_id %WinID%
        WinGetClass,       Win_Class, ahk_id %WinID%
        WinGetActiveTitle, Win_Active

        Match := 0
        If Win_Title in %TitleList%
            Match := 1
        If Win_Class in %ClassList%
            Match := 1
        If InStr(Win_Class, "USurface") ;Steam Fix
        OR InStr(Win_Class, "Trillian") ;Trillian Fix
        OR InStr(Win_Title, "Radial menu.ahk") ;Radial Menu Fix
            Match := 1

        If (Match = 1)        
        {
            Continue
        } Else {
            If ((Exiting = 1) || (Pausing = 1)) {
                TransVal := 255
            }
            Else If (Win_Title = Win_Active) {
                TransVal := ActiveTrans
            }
            Else {
                TransVal := InactiveTrans
            }
            WinSet, Transparent, %TransVal%, %Win_Title%
        }
    }
Return


EditSettings:
    Run, Edit %iniFile%
Return

PauseScript:
    Pausing = 1
    Menu, Tray, Disable, Pause Script
    Gosub TransWindows   
    Pause
    Pausing = 0
Return

ReloadScript:
    Menu, Tray, Enable, Pause Script
    Reload
Return

WriteSettings:
    IfExist, %iniFile%
    {
        MsgBox, 4,, Settings file already exists.`nDo you wish to create a new one?
        IfMsgBox, No
            Return
    }
    iniWrite, %Def_Time%, %iniFile%, Settings, Interval
    iniWrite, %Def_APct%, %iniFile%, Settings, Active_Trans
    iniWrite, %Def_IPct%, %iniFile%, Settings, Transparency
    iniWrite, %Blank%,    %iniFile%, Settings, Ignore_Title
    iniWrite, %Blank%,    %iniFile%, Settings, Ignore_Class
Return

Cleanup:
    Exiting = 1
    Gosub TransWindows
ExitScript:
ExitApp