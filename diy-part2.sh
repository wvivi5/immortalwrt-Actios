#!/bin/bash
# 修正固件只读
sed -i 's/remount,ro/remount,rw/g' package/base-files/files/lib/preinit/80_mount_root
# 强制 2.4G WiFi
sed -i 's/mode_band=.5g./mode_band="2g"/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh || true
sed -i '/ssid_5ghz/d' package/kernel/mac80211/files/lib/wifi/mac80211.sh || true
