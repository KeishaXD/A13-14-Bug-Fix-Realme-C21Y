#!/system/bin/sh
LATESTARTSERVICE=true


# Menampilkan informasi awal
ui_print "=========================================="
ui_print "            MODULE INFO                 "
ui_print "=========================================="
ui_print "    Name             : A13+ Bug Fix Realme C21Y"
ui_print "    Version          : 1.8"
ui_print "    Author           : KeishaXD"
ui_print "    Support Root     : Magisk / KernelSU / APatch"
ui_print "=========================================="
ui_print " "
sleep 1


# Menampilkan informasi perangkat
ui_print "    📱 DEVICE INFORMATION 📱"
ui_print "------------------------------------------"
ui_print "    DEVICE         : $(getprop ro.build.product)"
ui_print "    MODEL          : $(getprop ro.product.model)"
ui_print "    MANUFACTURER   : $(getprop ro.product.manufacturer)"
ui_print "    PROCESSOR      : $(getprop ro.product.board)"
ui_print "    CPU            : $(getprop ro.hardware)"
ui_print "    ANDROID VERSION: $(getprop ro.build.version.release)"
ui_print "    KERNEL VERSION : $(uname -r)"
ui_print "    RAM            : $(free -m | grep Mem | awk '{print $2" MB"}')"
ui_print "------------------------------------------"
ui_print " "
sleep 1


# Menampilkan status pemasangan modul
ui_print "📦 INSTALLING MODULES... 📦"
ui_print "=========================================="
ui_print " "
sleep 1

# === Helper function for permissions ===
set_file_perm() {
  local FILE=$1
  local MODE=$2
  if [ -f "$FILE" ]; then
    chmod "$MODE" "$FILE" && ui_print "✔ Permission set $MODE for $FILE" || ui_print "✖ Failed to set permission for $FILE"
  fi
}

fix_dir_files() {
  local DIR=$1
  if [ -d "$DIR" ]; then
    chmod 755 "$DIR"
    chown 0:0 "$DIR"
    echo "Fixed dir: $DIR" >> "$LOG"
    for f in "$DIR"/*; do
      if [ -f "$f" ]; then
        case "$f" in
          *.sh)   chmod 755 "$f"; chown 0:0 "$f"; echo "Script: $f" >> "$LOG" ;;
          *.xml|*.ini|*.conf|*.so) chmod 644 "$f"; chown 0:0 "$f"; echo "Config/Lib: $f" >> "$LOG" ;;
          *)      chmod 644 "$f"; chown 0:0 "$f"; echo "Other file: $f" >> "$LOG" ;;
        esac
      elif [ -d "$f" ]; then
        fix_dir_files "$f"
      fi
    done
  fi
}

# === Set script permissions first ===
ui_print "🔑 Setting script permissions..."
set_file_perm "$MODPATH/service.sh" 0755
set_file_perm "$MODPATH/post-fs-data.sh" 0755

# === Set vendor permissions ===
ui_print "🔑 Setting vendor permissions..."
[ -d "$MODPATH/system/vendor/bin" ] && chmod -R 755 "$MODPATH/system/vendor/bin" && chown -R 0:2000 "$MODPATH/system/vendor/bin" && echo "Fixed vendor/bin" >> "$LOG"
[ -d "$MODPATH/system/vendor/lib" ] && chmod -R 755 "$MODPATH/system/vendor/lib" && chown -R 0:0 "$MODPATH/system/vendor/lib" && find "$MODPATH/system/vendor/lib" -type f -exec chmod 644 {} \; && echo "Fixed vendor/lib" >> "$LOG"
[ -d "$MODPATH/system/vendor/lib64" ] && chmod -R 755 "$MODPATH/system/vendor/lib64" && chown -R 0:0 "$MODPATH/system/vendor/lib64" && find "$MODPATH/system/vendor/lib64" -type f -exec chmod 644 {} \; && echo "Fixed vendor/lib64" >> "$LOG"
[ -d "$MODPATH/system/vendor/lib/hw" ] && chmod -R 755 "$MODPATH/system/vendor/lib/hw" && chown -R 0:0 "$MODPATH/system/vendor/lib/hw" && find "$MODPATH/system/vendor/lib/hw" -type f -exec chmod 644 {} \; && echo "Fixed vendor/lib/hw" >> "$LOG"
[ -d "$MODPATH/system/vendor/lib64/hw" ] && chmod -R 755 "$MODPATH/system/vendor/lib64/hw" && chown -R 0:0 "$MODPATH/system/vendor/lib64/hw" && find "$MODPATH/system/vendor/lib64/hw" -type f -exec chmod 644 {} \; && echo "Fixed vendor/lib64/hw" >> "$LOG"
[ -d "$MODPATH/system/vendor/etc" ] && fix_dir_files "$MODPATH/system/vendor/etc"

echo "=== Vendor permissions applied at $(date) ===" >> "$LOG"

ui_print " "
ui_print "✅ Installation Finished!"
ui_print "=========================================="