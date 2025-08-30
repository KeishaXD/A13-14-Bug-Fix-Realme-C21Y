#!/system/bin/sh
# Max 10W Charger Limit for Realme C21Y
# Runs at boot

MODLOG=/data/local/tmp/max10w_charger.log
echo "Max 10W Charger Module Running..." > $MODLOG

# Ensure root
if [ "$(id -u)" != "0" ]; then
  echo "Not running as root!" >> $MODLOG
  exit 1
fi

# Realme C21Y USB charging current limits (example paths, may vary)
# Check actual sysfs paths in /sys/class/power_supply/usb/

USB_PATH="/sys/class/power_supply/usb"

# Set max charging voltage and current
# 5V = 5000 mV, 2A = 2000 mA
for file in max_voltage_mv input_current_ma constant_charge_current_max_ma; do
  if [ -f "$USB_PATH/$file" ]; then
    echo "Setting $file..." >> $MODLOG
    case $file in
      max_voltage_mv)
        echo 5000 > "$USB_PATH/$file"
        ;;
      input_current_ma|constant_charge_current_max_ma)
        echo 2000 > "$USB_PATH/$file"
        ;;
    esac
  fi
done

echo "Charging limited to 5V 2A (10W)." >> $MODLOG

# Applies correct permissions for vendor folders and files

MODPATH=${0%/*}
LOG=/data/local/tmp/vendor_fix.log

echo "=== Realme Vendor Fix starting at $(date) ===" > "$LOG"

# Helper function: recursively fix dirs and files
fix_dir_files() {
  DIR=$1
  # Directory perms
  set_perm "$DIR" 0 0 0755
  for f in "$DIR"/*; do
    if [ -f "$f" ]; then
      case "$f" in
        *.sh)   set_perm "$f" 0 0 0755 ;;
        *.xml|*.ini|*.conf|*.so) set_perm "$f" 0 0 0644 ;;
        *)      set_perm "$f" 0 0 0644 ;;
      esac
    elif [ -d "$f" ]; then
      fix_dir_files "$f"   # recursive
    fi
  done
}

# 1) vendor/bin → executables
[ -d "$MODPATH/system/vendor/bin" ] && set_perm_recursive "$MODPATH/system/vendor/bin" 0 2000 0755 0755

# 2) vendor/lib & lib64 → libraries
[ -d "$MODPATH/system/vendor/lib" ] && set_perm_recursive "$MODPATH/system/vendor/lib" 0 0 0755 0644
[ -d "$MODPATH/system/vendor/lib64" ] && set_perm_recursive "$MODPATH/system/vendor/lib64" 0 0 0755 0644

# 3) vendor/lib/hw & lib64/hw → .so libraries
[ -d "$MODPATH/system/vendor/lib/hw" ] && set_perm_recursive "$MODPATH/system/vendor/lib/hw" 0 0 0755 0644
[ -d "$MODPATH/system/vendor/lib64/hw" ] && set_perm_recursive "$MODPATH/system/vendor/lib64/hw" 0 0 0755 0644

# 4) vendor/etc → configs & nested folders
[ -d "$MODPATH/system/vendor/etc" ] && fix_dir_files "$MODPATH/system/vendor/etc"

echo "=== Realme Vendor Fix completed at $(date) ===" >> "$LOG"

# Enable OTG 
echo "1" > /sys/class/power_supply/usb/otg_switcher