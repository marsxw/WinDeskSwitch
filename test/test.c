#include <windows.h>
#include <iostream>

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    if (uMsg == WM_INPUT)
    {
        UINT dwSize;
        GetRawInputData((HRAWINPUT)lParam, RID_INPUT, NULL, &dwSize, sizeof(RAWINPUTHEADER));
        LPBYTE lpb = new BYTE[dwSize];
        if (GetRawInputData((HRAWINPUT)lParam, RID_INPUT, lpb, &dwSize, sizeof(RAWINPUTHEADER)) == dwSize)
        {
            RAWINPUT *raw = (RAWINPUT *)lpb;
            if (raw->header.dwType == RIM_TYPEKEYBOARD)
            {
                std::cout << "Key: " << raw->data.keyboard.VKey << " State: " << raw->data.keyboard.Flags << std::endl;
            }
        }
        delete[] lpb;
    }
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

int main()
{
    WNDCLASS wc = {};
    wc.lpfnWndProc = WindowProc;
    wc.hInstance = GetModuleHandle(NULL);
    wc.lpszClassName = "RawInputWindow";

    RegisterClass(&wc);

    HWND hwnd = CreateWindowEx(0, "RawInputWindow", "Raw Input Example", 0, 0, 0, 100, 100, NULL, NULL, wc.hInstance, NULL);

    RAWINPUTDEVICE rid[1];
    rid[0].usUsagePage = 0x01;
    rid[0].usUsage = 0x06; // Keyboard
    rid[0].dwFlags = RIDEV_INPUTSINK;
    rid[0].hwndTarget = hwnd;

    RegisterRawInputDevices(rid, 1, sizeof(RAWINPUTDEVICE));

    MSG msg;
    while (GetMessage(&msg, NULL, 0, 0))
    {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    return 0;
}
