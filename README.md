# xToolWSLUtils
Small collection of tools to dev iOS apps on WSL using xtool

# Setup xtool on WSL
* Install Swift toolchain on Linux following <https://swift.org/install/linux>
* Install usbmuxd/libimobiledevice-utils
* Install/configure Xcode/xtool following <https://xtool.sh/documentation/xtool/installation-linux/>

# Steps to access idevices/iPhone from CLI :
## Option 1 (recommanded) : 
1. On Windows Host, install Apple Device from <htps://apps.microsoft.com/detail/9np83lwlpz9k?hl=fr-FR&gl=US>
2. Configure WSL2 networking so 127.0.0.1 inside WSL bind to 127.0.0.1 on Windows Host by setting
`networkingMode=mirrored`
in _.wslconfig_
3. Set environment with : 
`export USBMUXD_SOCKET_ADDRESS="127.0.0.1:27015"`
4. Your device should appear in `ideviceinfo`  
## Option 2: 
If you want to keep WSL2 networking to NAT then : 
1. On Windows Host, install Apple Device from <htps://apps.microsoft.com/detail/9np83lwlpz9k?hl=fr-FR&gl=US>
2. run the PowerShell script enableAppleDeviceForwarding.ps1 on your host :
`powershell.exe -ExecutionPolicy Bypass -File enableAppleDeviceForwarding.ps1` 
3.  Set environment with :
`export USBMUXD_SOCKET_ADDRESS="<the IP of Windows Host>:27015"`
4. Your device should appear in `ideviceinfo`
## Option 3:
You can use USBIPD to assign you iPhone/device to WSL with USB passthrough, but this methode will not let you access the device in Windows and WSL simultaneously. 
