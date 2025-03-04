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

keysDict["e"] := {"block": 1, "state": 0, "keysc": GetKeySC("e"), "keysc2": GetKeySC("PgUp")}
keysDict["d"] := {"block": 1, "state": 0, "keysc": GetKeySC("d"), "keysc2": GetKeySC("PgDn")}
keysDict["i"] := {"block": 1, "state": 0, "keysc": GetKeySC("i"), "keysc2": GetKeySC("Insert")}

keysDict["z"] := {"block": 1, "state": 0, "keysc": GetKeySC("z"), "keysc2_2_1": GetKeySC("LControl"), "keysc2_2_2": GetKeySC("/")}
keysDict["q"] := {"block": 1, "state": 0, "keysc": GetKeySC("q"), "keysc2_2_1": GetKeySC("LControl"), "keysc2_2_2": GetKeySC("Home")}
keysDict["w"] := {"block": 1, "state": 0, "keysc": GetKeySC("w"), "keysc2_2_1": GetKeySC("LControl"), "keysc2_2_2": GetKeySC("End")}

; keysDict["w"] := {"block": 1, "state": 0, "keysc": GetKeySC("w"), "keysc2_3_1": GetKeySC("LShift"), "keysc2_3_2": GetKeySC("LAlt"), "keysc2_3_3": GetKeySC("a")}

keysDict["RAlt"] := {"block": 1, "state": 0, "keysc": GetKeySC("RAlt"), "keysc2_single": GetKeySC("Home")}
keysDict["RControl"] := {"block": 1, "state": 0, "keysc": GetKeySC("RControl"), "keysc2_single": GetKeySC("End")}

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
            if (ObjHasKey(keysDict[keyName], "keysc2")){
                AHI.SendKeyEvent(deviceId, keysDict["LControl"].keysc, 0)
                AHI.SendKeyEvent(deviceId, keysDict["LAlt"].keysc, 0)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2 , 1)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2 , 0)
                Return
            }
            if (ObjHasKey(keysDict[keyName], "keysc2_2_1")){
                AHI.SendKeyEvent(deviceId, keysDict["LControl"].keysc, 0)
                AHI.SendKeyEvent(deviceId, keysDict["LAlt"].keysc, 0)

                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_2_1 , 1)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_2_2 , 1)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_2_1 , 0)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_2_2 , 0)
                Return
            }
            if (ObjHasKey(keysDict[keyName], "keysc2_3_1")){
                AHI.SendKeyEvent(deviceId, keysDict["LControl"].keysc, 0)
                AHI.SendKeyEvent(deviceId, keysDict["LAlt"].keysc, 0)

                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_3_1 , 1)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_3_2 , 1)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_3_3 , 1)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_3_1 , 0)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_3_2 , 0)
                AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc2_3_3 , 0)
                Return
            }
        }
    }

    if (ObjHasKey(keysDict[keyName], "keysc2_single")){
        AHI.SendKeyEvent(deviceId,keysDict[keyName].keysc2_single , keysDict[keyName].state)
        Return
    }

    AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc, keysDict[keyName].state) ; not target key, send to all
}

; #:WIN  ^:Ctrl !:Alt  +:Shift
; Map the middle button in Windows Terminal to Ctrl + Shift + V
#IfWinActive ahk_exe WindowsTerminal.exe ; For Windows Terminal
    MButton::Send ^+v ; Set the middle button to Ctrl + Shift + V
#IfWinActive

; Map Ctrl + Alt + G to WIN+V
^!G::Send #v ; Map Ctrl + Alt + G to WIN+V

; ; ban Ctrl + J for vmware
; #IfWinActive ahk_exe vmware.exe
;     ^j::return  ; 禁用 Ctrl + J
; #IfWinActive

; MButton::
;     Send, ^v  ; Set the middle button to paste
; return

^!1::  ; Ctrl + Alt + 1
    Run, "C:\Program Files\Google\Chrome\Application\chrome.exe"
return

^!2::  ; Ctrl + Alt + 2
    Run, code
return

^!3::  ; Ctrl + Alt + 3
    Run, "C:\Program Files (x86)\Tencent\WeChat\WeChat.exe"
return

^!4::  ; Ctrl + Alt + 4
    Run, calc.exe
return

^!Insert::
    DllCall("powrprof.dll\SetSuspendState", "UInt", 0, "UInt", 1, "UInt", 0)
return

#IfWinActive ahk_exe chrome.exe
    !1::Send ^1
    !2::Send ^2
    !3::Send ^3
    !4::Send ^4
    !5::Send ^5
#IfWinActives