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

keysList := []
keysList.Push({"block":1, "state": 0, "keysc": GetKeySC("LControl")})
keysList.Push({"block":1, "state": 0, "keysc": GetKeySC("LAlt")})
keysList.Push({"block":1, "state": 0, "keysc": GetKeySC("a")})
keysList.Push({"block":1, "state": 0, "keysc": GetKeySC("s")})
keysList.Push({"block":1, "state": 0, "keysc": GetKeySC("z")})

keysList1 := []
keysList1.Push({"block":1, "state": 0, "keysc": GetKeySC("RAlt"), "keysc2": GetKeySC("Home")}) ; RAlt map to home
keysList1.Push({"block":1, "state": 0, "keysc": GetKeySC("AppsKey"), "keysc2": GetKeySC("End")}) ; AppsKey map to end

for deviceId, device in DeviceList {
    if (device.IsMouse = 0) {
        for keyInd, key in keysList {
            AHI.UnsubscribeKey(deviceId, key.keysc)
            AHI.SubscribeKey(deviceId, key.keysc, key.block, Func("KeyEvent").Bind(deviceId, keyInd))
        }
        for keyInd, key in keysList1 {
            AHI.SubscribeKey(deviceId, key.keysc, key.block, Func("KeyEvent1").Bind(deviceId, keyInd))
        }
    }
}

KeyEvent(deviceId , keyInd, state) {
    ; ToolTip,   %deviceId%  %keyInd% %state%
    global keysList
    keysList[keyInd].state := state
    if (keysList[1].state && keysList[2].state && keyInd>2) {
        if(keysList[keyInd].state){
            GoToDesktopNumber(keyInd-3)
            Return
        }
    }
    AHI.SendKeyEvent(deviceId, keysList[keyInd].keysc, state) ; not target shotkey, don't block
}

KeyEvent1(deviceId , keyInd, state) {
    ; ToolTip,   %deviceId%  %keyInd% %state%
    global keysList1
    AHI.SendKeyEvent(deviceId, keysList1[keyInd].keysc2, state)
}
; #:WIN  ^:Ctrl !:Alt  +:Shift
; Map the middle button in Windows Terminal to Ctrl + Shift + V
#IfWinActive ahk_exe WindowsTerminal.exe ; For Windows Terminal
    MButton::Send ^+v ; Set the middle button to Ctrl + Shift + V
#IfWinActive

; Map Ctrl + Alt + G to WIN+V
^!G::Send #v ; Map Ctrl + Alt + G to WIN+V
