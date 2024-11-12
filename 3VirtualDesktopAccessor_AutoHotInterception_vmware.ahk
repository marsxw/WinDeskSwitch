currentDir := A_ScriptDir
SetWorkingDir, %currentDir%
#Include %A_ScriptDir%\Lib\AutoHotInterception.ahk

VDA_PATH := currentDir ".\Lib\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    DllCall(GoToDesktopNumberProc, "Int", num)
}

AHI := new AutoHotInterception()
keyboardId := 1
AHI.SubscribeKey(keyboardId, GetKeySC("Control"), false, Func("KeyEvent").Bind("ctrl"))
AHI.SubscribeKey(keyboardId, GetKeySC("Alt"), false, Func("KeyEvent").Bind("alt"))
AHI.SubscribeKey(keyboardId, GetKeySC("a"), false, Func("KeyEvent").Bind("a"))
AHI.SubscribeKey(keyboardId, GetKeySC("s"), false, Func("KeyEvent").Bind("s"))
AHI.SubscribeKey(keyboardId, GetKeySC("z"), false, Func("KeyEvent").Bind("z"))

ctrl_state :=  "Released"
alt_state :=  "Released"
a_state :=  "Released"
s_state :=  "Released"
z_state :=  "Released"

KeyEvent(keyName, state) {
    global ctrl_state, alt_state, a_state, s_state, z_state, hLvKeyboard
    Gui, ListView, % hLvKeyboard
    stateText := (state = 1) ? "Pressed" : "Released"

    if (keyName = "ctrl") {
        ctrl_state := stateText
    } else if (keyName = "alt") {
        alt_state := stateText
    } else if (keyName = "a") {
        a_state := stateText
    } else if (keyName = "s") {
        s_state := stateText
    } else if (keyName = "z") {
        z_state := stateText
    }

    ; ToolTip, %ctrl_state%   %alt_state%  %a_state%   %s_state%   %z_state%
    if (ctrl_state= "Pressed" && alt_state== "Pressed" ) {
        if(a_state== "Pressed" ){
            GoToDesktopNumber(0)  ; 切换到桌面 1
        }
        else if(s_state== "Pressed" ){
            GoToDesktopNumber(1)  ; 切换到桌面 2
        }
        else if(z_state== "Pressed" ){
            GoToDesktopNumber(2)  ; 切换到桌面 3
        }
    }
}

; Use the shortcut Ctrl + Alt + letter
^!A::GoToDesktopNumber(0)  ; Switch to desktop 1
^!S::GoToDesktopNumber(1)  ; Switch to desktop 2
^!Z::GoToDesktopNumber(2)  ; Switch to desktop 3

; #:WIN  ^:Ctrl !:Alt  +:Shift
; Map the middle button in Windows Terminal to Ctrl + Shift + V
#IfWinActive ahk_exe WindowsTerminal.exe ; For Windows Terminal
    MButton::Send ^+v ; Set the middle button to Ctrl + Shift + V
#IfWinActive

; Map Ctrl + Alt + G to WIN+V
^!G::Send #v ; Map Ctrl + Alt + G to WIN+V
