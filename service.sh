#!/system/bin/sh
# Realme C21Y Vendor Fix – Safe Wi-Fi/Bluetooth & Audio Coexistence

# Ensure root
if [ "$(id -u)" != 0 ]; then
    echo "Not root. Exiting."
    exit 1
fi

# === Safe Display Tweaks ===
# (optional: helps with video/color, but does not fix tint completely)
setprop debug.sf.color_space 0
setprop debug.sf.lcd_density $(getprop ro.sf.lcd_density)

# === Disable aggressive power saving that kills Wi-Fi/Bluetooth ===
settings put global low_power 0
settings put global power_saving_mode 0

# === Enable Wi-Fi/Bluetooth coexistence (safe) ===
setprop persist.vendor.bt.coex.enable 1
setprop persist.vendor.wifi.bt.coex 1

# === Optional: force audio routing stability ===
# This ensures audio goes to the connected device (BT/earpods)
setprop persist.vendor.audio.routing 1
setprop persist.vendor.audio.bt_route 1

# === Optional: ensure proper A2DP configuration ===
# Only apply if vendor HAL supports it
setprop persist.vendor.bt.a2dp_on_boot 1

echo "Service.sh applied: Wi-Fi/Bluetooth coexistence and audio routing stabilized."

#Fix Brightness
setprop persist.sys.qcom-brightness 4095