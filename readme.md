# Windows 11 Multi-Desktop Switching for Improved Development Efficiency
[中文](./readme_cn.md)

Switching between multiple desktops can significantly enhance productivity. On Ubuntu, the multi-desktop functionality is seamless, allowing you to quickly switch to specific desktops with assigned hotkeys. However, on Windows, you're limited to sequential desktop switching using `Ctrl + Win + Left/Right` keys, and unfortunately, there's no official improvement from Microsoft on this front. Standard key mapping tools like PowerToys and AutoHotkey can only remap keys to these sequential desktop-switching commands, essentially still navigating desktops one by one.

Thanks to the VirtualDesktopAccessor library ([VirtualDesktopAccessor GitHub Repository](https://github.com/Ciantic/VirtualDesktopAccessor/releases/)), you can achieve fast desktop switching on Windows 11.

### Background and Challenge

On Windows, development is not as convenient as on Ubuntu. Frequent switching between the Windows host and Ubuntu virtual machine (VM) becomes tedious because you need to release the mouse from the VM (using `Ctrl + Alt`) every time to switch desktops. Tools like VMware capture all input, preventing desktop switching while inside the VM.

Since AutoHotkey on the host cannot directly intercept keyboard inputs within the VM, a lower-level hook is required to capture them. Here, we utilize evilC's [AutoHotInterception library](https://github.com/evilC/AutoHotInterception?tab=readme-ov-file), which enables us to capture input at a low level, allowing for seamless desktop switching on Windows 11 from any environment.

### Implementation

In this setup, I configured `Ctrl + Alt + A/S/D` as shortcuts to switch between desktops. This assumes you have created three desktops in Windows 11. Pressing `Ctrl + Alt + A` will switch to the first desktop, `Ctrl + Alt + S` to the second, and `Ctrl + Alt + D` to the third. This setup enables quick desktop switching from any location on Windows 11. You can modify the shortcuts in the AutoHotkey (AHK) script to suit your own preferences.

### Key AHK Files

1. **`VirtualDesktopAccessor.ahk`**  
   This method enables multi-desktop switching on Windows 11, but it fails to work inside VMware.

2. **`VirtualDesktopAccessor_vmware.ahk` and `VirtualDesktopAccessor_vmware.py`**  
   This second method allows seamless desktop switching on Windows 11, even within VMware. A Python script in the Ubuntu VM listens for specific hotkeys and writes the detected keys to a shared file, signaling the host to switch desktops (a TCP method could also be used, but file-writing is simpler here).

3. **`VirtualDesktopAccessor_AutoHotInterception_vmware`**  
   The third method is the most versatile. By using low-level keyboard input interception, it enables fast desktop switching from anywhere on Windows 11.

### Additional Notes

For faster desktop switching back to Windows from VMware, you can use `vmware-kvm.exe` with configured parameters to share a single desktop between Windows and VMware. For more details, refer to VMware's official documentation: [VMware KVM Guide](https://docs.vmware.com/en/VMware-Workstation-Pro/15.0/vmware-kvm.pdf).
