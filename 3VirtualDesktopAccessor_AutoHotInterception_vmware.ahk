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
    DllCall(GoToDesktopNumberProc, "Int", num)
}

global AHI := new AutoHotInterception()
DeviceList := AHI.GetDeviceList()

keysDict := {}
keysDict["LControl"] := {"block": 1, "state": 0, "keysc": GetKeySC("LControl")}
keysDict["LAlt"] := {"block": 1, "state": 0, "keysc": GetKeySC("LAlt")}
keysDict["a"] := {"block": 1, "state": 0, "keysc": GetKeySC("a")}
keysDict["s"] := {"block": 1, "state": 0, "keysc": GetKeySC("s")}
keysDict["z"] := {"block": 1, "state": 0, "keysc": GetKeySC("z")}
keysDict["q"] := {"block": 1, "state": 0, "keysc": GetKeySC("q"), "keysc2": GetKeySC("Home")}
keysDict["w"] := {"block": 1, "state": 0, "keysc": GetKeySC("w"), "keysc2": GetKeySC("End")}
keysDict["Delete"] := {"block": 1, "state": 0, "keysc": GetKeySC("Delete"), "keysc2": GetKeySC("Insert")}
AAA
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
        if( keysDict["a"].state){
            GoToDesktopNumber(0)
            Return
        }
        if (keysDict["s"].state) {
            GoToDesktopNumber(1)
            Return
        }
        if (keysDict["z"].state) {
            GoToDesktopNumber(2)
            Return
        }
        if (keysDict["q"].state) {
            AHI.SendKeyEvent(deviceId, keysDict["LControl"].keysc, 0)
            AHI.SendKeyEvent(deviceId, keysDict["LAlt"].keysc, 0)

            AHI.SendKeyEvent(deviceId, keysDict["q"].keysc2, 1)
            AHI.SendKeyEvent(deviceId, keysDict["q"].keysc2, 0)
            Return
        }
        if (keysDict["w"].state) {
            AHI.SendKeyEvent(deviceId, keysDict["LControl"].keysc, 0)
            AHI.SendKeyEvent(deviceId, keysDict["LAlt"].keysc, 0)

            AHI.SendKeyEvent(deviceId, keysDict["w"].keysc2, 1)
            AHI.SendKeyEvent(deviceId, keysDict["w"].keysc2, 0)
            Return
        }
        if (keysDict["Delete"].state) {
            AHI.SendKeyEvent(deviceId, keysDict["LControl"].keysc, 0)
            AHI.SendKeyEvent(deviceId, keysDict["LAlt"].keysc, 0)

            AHI.SendKeyEvent(deviceId, keysDict["Delete"].keysc2, 1)
            AHI.SendKeyEvent(deviceId, keysDict["Delete"].keysc2, 0)
            Return
        }
    }

    AHI.SendKeyEvent(deviceId, keysDict[keyName].keysc, state)
}

; #:WIN  ^:Ctrl !:Alt  +:Shift
; Map the middle button in Windows Terminal to Ctrl + Shift + V
#IfWinActive ahk_exe WindowsTerminal.exe ; For Windows Terminal
    MButton::Send ^+v ; Set the middle button to Ctrl + Shift + V
#IfWinActive

; Map Ctrl + Alt + G to WIN+V
^!G::Send #v ; Map Ctrl + Alt + G to WIN+V
