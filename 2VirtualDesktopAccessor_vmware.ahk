VDA_PATH := "./Lib/VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")

GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")

GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    Send, ^{Alt}  ; Release focus from VMware or other capturing apps
    DllCall(GoToDesktopNumberProc, "Int", num)
}

; VMware switch back to Windows
; Define the shared file path
sharedFilePath := "C:\Users\marswen\switch_command.txt"
lastModified := ""  ; Used to store the last detected file modification time
SetTimer, CheckSwitchFile, 100

CheckSwitchFile:
    if FileExist(sharedFilePath) {
        ; Get the current file's last modification time
        FileGetTime, currentModified, %sharedFilePath%, M

        if (lastModified=""){
            lastModified := currentModified  ; Record the modification time on the first read
        }
        else if(currentModified != lastModified) {
            ; If the modification time differs from the last recorded time, read the file content and perform actions
            lastModified := currentModified  ; Update the recorded modification time

            ; Read the file content
            FileRead, content, %sharedFilePath%

            ; Perform actions based on content
            if (content = "SWITCH_DESKTOP_A") {
                GoToDesktopNumber(0)  ; Switch to Desktop 1
            } else if (content = "SWITCH_DESKTOP_S") {
                GoToDesktopNumber(1)  ; Switch to Desktop 2
            } else if (content = "SWITCH_DESKTOP_Z") {
                GoToDesktopNumber(2)  ; Switch to Desktop 3
            }
        }
    }
return

; Use the shortcut Ctrl + Alt + letter
^!A::GoToDesktopNumber(0)  ; Switch to Desktop 1
^!S::GoToDesktopNumber(1)  ; Switch to Desktop 2
^!Z::GoToDesktopNumber(2)  ; Switch to Desktop 3

; #: WIN  ^: Ctrl !: Alt  +: Shift  
; Map middle button in Windows Terminal to Ctrl + Shift + V
#IfWinActive ahk_exe WindowsTerminal.exe ; For Windows Terminal
MButton::Send ^+v ; Set the middle button to Ctrl + Shift + V
#IfWinActive

; Map Ctrl + Alt + G to WIN+V
^!G::Send #v ; Map Ctrl + Alt + G to WIN+V
