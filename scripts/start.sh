#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "com.termux.x11.Loader" 2>/dev/null
sleep 1

am start --user 0 -n com.termux.x11/.MainActivity > /dev/null 2>&1
sleep 2

termux-x11-preference "fullscreen:true"
termux-x11-preference "displayStretch:true"
termux-x11-preference "adjustResolution:true"
termux-x11-preference "displayResolutionMode:custom"
termux-x11-preference "displayResolutionCustom:720x1280" # Замените на разрешение вашего экрана

termux-x11 :0 &
sleep 2

proot-distro login debian --shared-tmp --bind /sdcard/Download:/root/Downloads/Android -- env DISPLAY=:0 dbus-run-session -- chromium --no-sandbox --window-size=720,1280 --window-position=0,0 --download-directory="/root/Downloads/Android" > /dev/null 2>&1 &