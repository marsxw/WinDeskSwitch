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
keysDict["z"] := {"block": 1, "state": 0, "keysc": GetKeySC("z"), "desktop": 3}
keysDict["q"] := {"block": 1, "state": 0, "keysc": GetKeySC("q"), "keysc2": GetKeySC("Home")}
keysDict["w"] := {"block": 1, "state": 0, "keysc": GetKeySC("w"), "keysc2": GetKeySC("End")}
keysDict["e"] := {"block": 1, "state": 0, "keysc": GetKeySC("e"), "keysc2": GetKeySC("PgUp")}
keysDict["d"] := {"block": 1, "state": 0, "keysc": GetKeySC("d"), "keysc2": GetKeySC("PgDn")}
keysDict["i"] := {"block": 1, "state": 0, "keysc": GetKeySC("i"), "keysc2": GetKeySC("Insert")}

SetTimer, CheckDeviceStatus, 1000
CheckDeviceStatus:
    DeviceList := AHI.GetDeviceList()
    for deviceId, device in DeviceList {
        if (device.IsMouse = 0) {
            update := False
            for keyName, keyData in keysDict {
                if (AHI.IsSubscribed(deviceId, keyData.keysc)) {
                    continue
                }
                AHI.SubscribeKey(deviceId, keyData.keysc, keyData.block, Func("KeyEvent").Bind(deviceId, keyName))
                update := True
            }
            if (update) {
                ToolTip, keyboard update: %deviceId%
                Sleep, 1000

            }
        }
    }
    ToolTip ;
Return

KeyEvent(deviceId, keyName, state) {
    ; ToolTip,   %deviceId%  %keyName% %state%
    global keysDict
    keysDict[keyName].state := state

    if (keysDict["LControl"].state && keysDict["LAlt"].state) {
        for _, keyData in keysDict {
            if(keyData["state"]){
                if  (ObjHasKey(keyData, "desktop")){
                    GoToDesktopNumber(keyData["desktop"])
                    Return
                }
                if (ObjHasKey(keyData, "keysc2")){
                    AHI.SendKeyEvent(deviceId, keysDict["LControl"].keysc, 0)
                    AHI.SendKeyEvent(deviceId, keysDict["LAlt"].keysc, 0)
                    AHI.SendKeyEvent(deviceId, keyData["keysc2"] , 1)
                    AHI.SendKeyEvent(deviceId, keyData["keysc2"] , 0)
                    Return
                }
            }
        }
    }

    AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc, state) ; not target key, send to all
}

; #:WIN  ^:Ctrl !:Alt  +:Shift
; Map the middle button in Windows Terminal to Ctrl + Shift + V
#IfWinActive ahk_exe WindowsTerminal.exe ; For Windows Terminal
    MButton::Send ^+v ; Set the middle button to Ctrl + Shift + V
#IfWinActive

; Map Ctrl + Alt + G to WIN+V
^!G::Send #v ; Map Ctrl + Alt + G to WIN+V
