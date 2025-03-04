import usb.core
import usb.util

# 列出所有 USB 设备
devices = usb.core.find(find_all=True)

print("Connected USB devices:")
for device in devices:
    print(f"Vendor ID: {hex(device.idVendor)}, Product ID: {hex(device.idProduct)}")
    print(f"  Manufacturer: {usb.util.get_string(device, device.iManufacturer)}")
    print(f"  Product: {usb.util.get_string(device, device.iProduct)}")
    print("-" * 40)

keyboard
kbdclass
