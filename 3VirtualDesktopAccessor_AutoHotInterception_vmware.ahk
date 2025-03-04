#SingleInstance force
#Persistent
currentDir := A_ScriptDir
SetWorkingDir, %currentDir%
#Include %A_ScriptDir%\Lib\AutoHotInterception.ahk

VDA_PATH := currentDir ".\Lib\VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")
GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    DllCall(GoToDesktopNumberProc, "Int", num-1)
}

global AHI := new AutoHotInterception()
keysDict := {}
keysDict["LControl"] := {"block": 1, "state": 0, "keysc": GetKeySC("LControl")}
keysDict["LAlt"] := {"block": 1, "state": 0, "keysc": GetKeySC("LAlt")}
keysDict["a"] := {"block": 1, "state": 0, "keysc": GetKeySC("a"), "desktop": 1}
keysDict["s"] := {"block": 1, "state": 0, "keysc": GetKeySC("s"), "desktop": 2}
keysDict["x"] := {"block": 1, "state": 0, "keysc": GetKeySC("x"), "desktop": 3}

DeviceList := AHI.GetDeviceList()
for deviceId, device in DeviceList {
    if (device.IsMouse = 0) {
        for keyName, keyData in keysDict {
            AHI.UnsubscribeKey(deviceId, keyData.keysc)
            AHI.SubscribeKey(deviceId, keyData.keysc, keyData.block, Func("KeyEvent").Bind(deviceId, keyName))
        }
    }
}

KeyEvent(deviceId, keyName, state) {
    ; ToolTip,   %deviceId%  %keyName% %state%
    global keysDict
    keysDict[keyName].state := state

    if (keysDict["LControl"].state && keysDict["LAlt"].state) {
        if(keysDict[keyName].state){
            if  (ObjHasKey(keysDict[keyName], "desktop")){
                GoToDesktopNumber(keysDict[keyName].desktop)
                Return
            }
        }
    }
    AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc, keysDict[keyName].state) ; not target key, send to all
}

^!XButton2:: Send, {Left} ; Ctrl + Alt + Mouse Back (侧键后退)
^!XButton1:: Send, {Right} ; Ctrl + Alt + Mouse Forward (侧键前进)
^!WheelUp:: Send, {Up} ; Ctrl + Alt + Mouse Wheel Up
^!WheelDown::  Send, {Down}  ; Ctrl + Alt + Mouse Wheel Down

^MButton:: Send, {Enter}  ; Ctrl + Middle Mouse Button
^XButton2:: Send, {Backspace} ; Ctrl + Mouse Side Button
^XButton1:: Send, {Delete} ; Ctrl + Mouse Side Button
^!G::Send #v ; Map Ctrl + Alt + G to WIN+V
^!z::Send ^/
RAlt::Home
RControl::End

^!q::Send, ^{Home}
^!w::Send, ^{End}
^!e::Send, {PgUp}
^!d::Send, {PgDn}

; #:WIN  ^:Ctrl !:Alt  +:Shift
; Map the middle button in Windows Terminal to Ctrl + Shift + V
#IfWinActive ahk_exe WindowsTerminal.exe ; For Windows Terminal
    MButton::Send ^+v ; Set the middle button to Ctrl + Shift + V
#IfWinActive

#IfWinActive ahk_exe chrome.exe
    !1::Send ^1
    !2::Send ^2
    !3::Send ^3
    !4::Send ^4
    !5::Send ^5
#IfWinActive

^!F4::
    Run, nircmd.exe changebrightness -10
Return
^!F5:: Run, nircmd.exe changebrightness +10
^!F11:: Run, %ComSpec% /c C:\Windows\System32\DisplaySwitch.exe /internal, , Hide
^!F12:: Run, %ComSpec% /c C:\Windows\System32\DisplaySwitch.exe /extend, , Hide

^!1:: Run, "C:\Program Files\Google\Chrome\Application\chrome.exe"
^!2:: Run, code
^!3:: Run, "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
^!4:: Run, calc.exe
^!5:: Run, "C:\Program Files (x86)\VMware\VMware Workstation\vmware.exe"
^!Insert:: DllCall("powrprof.dll\SetSuspendState", "UInt", 0, "UInt", 1, "UInt", 0)

