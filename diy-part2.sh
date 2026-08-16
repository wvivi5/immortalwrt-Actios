#!/bin/bash
# 修正固件只读
sed -i 's/remount,ro/remount,rw/g' package/base-files/files/lib/preinit/80_mount_root
# 强制 2.4G WiFi
sed -i 's/mode_band=.5g./mode_band="2g"/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh || true
sed -i '/ssid_5ghz/d' package/kernel/mac80211/files/lib/wifi/mac80211.sh || true

# ===== [1] daed 需要 IPv4 策略路由 (2026-08-16 修复) =====
# IP_ADVANCED_ROUTER / IP_MULTIPLE_TABLES 未在 config/Config-kernel.in 声明,
# 所以 .config 里写 CONFIG_KERNEL_ 前缀会被 make defconfig 静默丢弃(实测已验证)。
# 必须直接写入目标内核配置文件, 才能真正编进内核。
for KCFG in target/linux/msm89xx/config-6.12 target/linux/msm89xx/config-default; do
  [ -f "$KCFG" ] || continue
  sed -i '/CONFIG_IP_ADVANCED_ROUTER/d; /CONFIG_IP_MULTIPLE_TABLES/d' "$KCFG"
  echo 'CONFIG_IP_ADVANCED_ROUTER=y' >> "$KCFG"
  echo 'CONFIG_IP_MULTIPLE_TABLES=y' >> "$KCFG"
done

# ===== [2] 原生 OTG 自动切换 (复刻 3 号机制, 2026-08-16) =====
# 3号(可自动切)靠 extcon-usb-gpio 读 gpio110(USB ID针脚): 插电脑=device, 插网卡=host。
# 2号新固件 extcon 绑的是 pm8916_usbin(只测通电,永远USB-HOST=0)。
# 复刻: 把 extcon 改指 gpio110 的 usb-id 节点, 去掉软件 usb-role-switch (纯OTG,同3号)。
DTSI=target/linux/msm89xx/dts/msm8916-sp970.dtsi
if [ -f "$DTSI" ]; then
  sed -i 's/extcon = <&pm8916_usbin>;/extcon = <\&usb_id>;/g' "$DTSI"
  sed -i '/usb-role-switch;/d' "$DTSI"
  cat >> "$DTSI" <<'EODTS'

/ {
	usb_id: usb-id {
		compatible = "linux,extcon-usb-gpio";
		id-gpio = <&tlmm 110 GPIO_ACTIVE_HIGH>;
		pinctrl-names = "default";
		pinctrl-0 = <&usb_id_default>;
	};
};

&tlmm {
	usb_id_default: usb-id-default-state {
		pins = "gpio110";
		function = "gpio";
		bias-pull-up;
		input-enable;
	};
};
EODTS
fi
