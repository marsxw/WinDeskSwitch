# 提高开发效率的 Windows 11 多桌面切换方案
[English](./readme.md)

多桌面切换可以显著提高工作效率。在 Ubuntu 上，多桌面功能十分完善，可以通过快捷键快速切换到指定桌面。然而，在 Windows 上只能通过 `Ctrl + Win + 左/右方向键` 逐个切换桌面，不幸的是，微软官方对此并没有改进。像 PowerToys 和 AutoHotkey 这样的键位映射工具仅能将按键映射到这些逐个切换的命令上，实际上还是需要一个一个地切换桌面。

感谢 [VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor/releases/) 库的支持，现在可以在 Windows 11 上实现快速桌面切换。

### 背景和挑战

在 Windows 上的开发体验不如在 Ubuntu 上方便。频繁在 Windows 主机和 Ubuntu 虚拟机之间切换变得很繁琐，因为每次都需要通过 `Ctrl + Alt` 从虚拟机中释放鼠标，才能切换到主机桌面。类似 VMware 的工具会捕获所有输入，导致在虚拟机中无法再次切换主机桌面。

由于主机上的 AutoHotkey 无法直接监听虚拟机中的按键输入，需要使用底层钩子来捕获输入。在这里，我们利用了 evilC 的 [AutoHotInterception](https://github.com/evilC/AutoHotInterception?tab=readme-ov-file) 库，可以在低层捕获输入，从而实现在 Windows 11 的任意环境中无缝切换桌面。

### 实现方法

在本方案中，我配置了 `Ctrl + Alt + A/S/D` 作为切换桌面的快捷键，前提是你已经在 Windows 11 中创建了三个桌面。按下 `Ctrl + Alt + A` 会切换到第一个桌面，按下 `Ctrl + Alt + S` 会切换到第二个桌面，按下 `Ctrl + Alt + D` 会切换到第三个桌面。这一设置可以在 Windows 11 的任何位置实现快速桌面切换。你可以在 AHK 脚本中根据自己的需求修改快捷键。

### 关键 AHK 文件说明

1. **`VirtualDesktopAccessor.ahk`**  
   这种方法可以在 Windows 11 上实现多桌面切换，但在 VMware 中无效。

2. **`VirtualDesktopAccessor_vmware.ahk` 和 `VirtualDesktopAccessor_vmware.py`**  
   第二种方法可以在 VMware 中正常使用。Ubuntu 虚拟机中的 Python 脚本监听特定快捷键，并将检测到的按键写入共享文件，通知主机切换桌面（也可以通过 TCP 方式实现，但写入文件更为简单）。

3. **`VirtualDesktopAccessor_AutoHotInterception_vmware`**  
   第三种方法是最通用的。通过底层键盘输入拦截，可以实现在 Windows 11 的任意位置快速切换桌面。

### 其他说明

为了更快地从 VMware 切换回 Windows 桌面，你可以使用 `vmware-kvm.exe` 配置参数，使 Windows 和 VMware 共用一个桌面。有关更多详细信息，请参阅 VMware 的官方文档：[VMware KVM 指南](https://docs.vmware.com/en/VMware-Workstation-Pro/15.0/vmware-kvm.pdf)。

![Effect](result.gif)
