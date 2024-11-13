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
DeviceList := AHI.GetDeviceList()

for deviceId, device in DeviceList {
    GuiControlGet, state, , % hwnd
    if (device.IsMouse = 0) {
        AHI.SubscribeKey(deviceId, GetKeySC("Control"), false, Func("KeyEvent").Bind("ctrl"))
        AHI.SubscribeKey(deviceId, GetKeySC("Alt"), false, Func("KeyEvent").Bind("alt"))
        AHI.SubscribeKey(deviceId, GetKeySC("a"), false, Func("KeyEvent").Bind("a"))
        AHI.SubscribeKey(deviceId, GetKeySC("s"), false, Func("KeyEvent").Bind("s"))
        AHI.SubscribeKey(deviceId, GetKeySC("z"), false, Func("KeyEvent").Bind("z"))
    }
}

ctrl_state := 0
alt_state := 0
a_state :=  0
s_state := 0
z_state :=  0

KeyEvent(keyName, state) {
    global ctrl_state, alt_state, a_state, s_state, z_state, hLvKeyboard
    Gui, ListView, % hLvKeyboard
    scanCode := Format("{:x}", code)

    if (keyName = "ctrl") {
        ctrl_state := state
    } else if (keyName = "alt") {
        alt_state := state
    } else if (keyName = "a") {
        a_state := state
    } else if (keyName = "s") {
        s_state := state
    } else if (keyName = "z") {
        z_state := state
    }

    ; ToolTip, %keyName%  %state%
    ; ToolTip, %ctrl_state%   %alt_state%  %a_state%   %s_state%   %z_state%
    if (ctrl_state && alt_state  ) {
        if(a_state){
            GoToDesktopNumber(0)
        }
        else if(s_state){
            GoToDesktopNumber(1)
        }
        else if(z_state){
            GoToDesktopNumber(2)
        }
    }
}

; #:WIN  ^:Ctrl !:Alt  +:Shift
; Map the middle button in Windows Terminal to Ctrl + Shift + V
#IfWinActive ahk_exe WindowsTerminal.exe ; For Windows Terminal
    MButton::Send ^+v ; Set the middle button to Ctrl + Shift + V
#IfWinActive

; Map Ctrl + Alt + G to WIN+V
^!G::Send #v ; Map Ctrl + Alt + G to WIN+V

