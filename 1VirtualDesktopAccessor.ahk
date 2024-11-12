VDA_PATH := "./Lib/VirtualDesktopAccessor.dll"
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", VDA_PATH, "Ptr")
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")

GoToDesktopNumber(num) {
    global GoToDesktopNumberProc
    Send, ^{Alt}
    DllCall(GoToDesktopNumberProc, "Int", num)
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
