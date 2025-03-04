#include Lib\ViGEm.ahk
#include Lib\AutoHotInterception.ahk

AHI := new AutoHotInterception()
ViGEm := new ViGEm()

; 创建虚拟键盘
virtualKeyboard := ViGEm.CreateKeyboard()

; 捕获蓝牙键盘输入
bluetoothVID := 0x1234
bluetoothPID := 0x5678

devices := AHI.GetDeviceList()
foreach (deviceId, device in devices) {
    if (device.vid == bluetoothVID && device.pid == bluetoothPID) {
        AHI.SubscribeKeyDown(device.handle, "*", Func("RedirectToVirtualKeyboard"))
        MsgBox, 已捕获蓝牙键盘
        break
    }
}

RedirectToVirtualKeyboard(scanCode, vkCode, isUp, deviceHandle) {
    global virtualKeyboard
    ; 将输入事件发送到虚拟键盘
    virtualKeyboard.SendKey(vkCode, isUp)
}
