#!/bin/bash
# 修正固件只读
sed -i 's/remount,ro/remount,rw/g' package/base-files/files/lib/preinit/80_mount_root
# 强制 2.4G WiFi
sed -i 's/mode_band=.5g./mode_band="2g"/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh || true
sed -i '/ssid_5ghz/d' package/kernel/mac80211/files/lib/wifi/mac80211.sh || true

# ===== daed 需要 IPv4 策略路由 (2026-08-16 修复) =====
# IP_ADVANCED_ROUTER / IP_MULTIPLE_TABLES 未在 config/Config-kernel.in 声明,
# 所以 .config 里写 CONFIG_KERNEL_ 前缀会被 make defconfig 静默丢弃(实测已验证)。
# 必须直接写入目标内核配置文件, 才能真正编进内核。
for KCFG in target/linux/msm89xx/config-6.12 target/linux/msm89xx/config-default; do
  [ -f "$KCFG" ] || continue
  sed -i '/CONFIG_IP_ADVANCED_ROUTER/d; /CONFIG_IP_MULTIPLE_TABLES/d' "$KCFG"
  echo 'CONFIG_IP_ADVANCED_ROUTER=y' >> "$KCFG"
  echo 'CONFIG_IP_MULTIPLE_TABLES=y' >> "$KCFG"
done
