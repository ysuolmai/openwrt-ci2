#!/bin/bash

# 修改默认IP
# sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4

	# 清理旧的包
	read -ra PKG_NAMES <<< "$PKG_NAME"  # 将PKG_NAME按空格分割成数组
	for NAME in "${PKG_NAMES[@]}"; do
		rm -rf $(find feeds/luci/ feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" -prune)
	done

	# 克隆仓库
	if [[ $PKG_REPO == http* ]]; then
		local REPO_NAME=$(echo $PKG_REPO | awk -F '/' '{gsub(/\.git$/, "", $NF); print $NF}')
		git clone --depth=1 --single-branch --branch $PKG_BRANCH "$PKG_REPO" package/$REPO_NAME
	else
		local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)
		git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git" package/$REPO_NAME
	fi

	# 根据 PKG_SPECIAL 处理包
	case "$PKG_SPECIAL" in
		"pkg")
			# 提取每个包
			for NAME in "${PKG_NAMES[@]}"; do
				cp -rf $(find ./package/$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$NAME*" -prune) ./package/
			done
			# 删除剩余的包
			rm -rf ./package/$REPO_NAME/
			;;
		"name")
			# 重命名包
			mv -f ./package/$REPO_NAME ./package/$PKG_NAME
			;;
	esac
}


# 添加额外插件
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff

# 科学上网插件
#UPDATE_PACKAGE "homeproxy" "https://github.com/VIKINGYFY/homeproxy.git" "main"
#UPDATE_PACKAGE "luci-app-adguardhome" "https://github.com/ysuolmai/luci-app-adguardhome.git" "master"
# Themes
#UPDATE_PACKAGE "argon" "sbwml/luci-theme-argon" "openwrt-24.10"



#DDNS-go
git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go

#luci-app-zerotier
git clone https://github.com/rufengsuixing/luci-app-zerotier.git package/luci-app-zerotier


#tailscale
#sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile
#git clone https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale

#gecoosac
#git clone https://github.com/lwb1978/openwrt-gecoosac package/openwrt-gecoosac

#lucky
#git clone  https://github.com/gdy666/luci-app-lucky.git package/lucky

#alist
UPDATE_PACKAGE "alist" "https://github.com/sbwml/luci-app-alist.git" "main"

#small-package
UPDATE_PACKAGE "xray-core xray-plugin dns2tcp dns2socks haproxy hysteria \
        naiveproxy shadowsocks-rust sing-box v2ray-core v2ray-geodata v2ray-geoview v2ray-plugin \
        tuic-client chinadns-ng ipt2socks tcping trojan-plus simple-obfs shadowsocksr-libev \
        luci-app-passwall alist luci-app-alist smartdns luci-app-smartdns v2dat mosdns luci-app-mosdns \
        taskd luci-lib-xterm luci-lib-taskd \
        luci-app-store quickstart luci-app-quickstart luci-app-istorex luci-app-cloudflarespeedtest \
        luci-theme-argon netdata luci-app-netdata lucky luci-app-lucky luci-app-openclash mihomo \
        luci-app-mihomo luci-app-amlogic" "kenzok8/small-package" "main" "pkg"

#speedtest
UPDATE_PACKAGE "luci-app-netspeedtest" "https://github.com/sbwml/openwrt_pkgs.git" "main" "pkg"
UPDATE_PACKAGE "speedtest-cli" "https://github.com/sbwml/openwrt_pkgs.git" "main" "pkg"

UPDATE_PACKAGE "luci-app-adguardhome" "https://github.com/ysuolmai/luci-app-adguardhome.git" "master"

keywords_to_delete=(
    "xiaomi_ax3600" "xiaomi_ax9000" "xiaomi_ax1800" "glinet" "jdcloud_ax6600"
    "mr7350" "uugamebooster" "luci-app-wol" "luci-i18n-wol-zh-cn" "CONFIG_TARGET_INITRAMFS" "ddns" "LSUSB" "mihomo"
)


[[ $FIRMWARE_TAG == *"NOWIFI"* ]] && keywords_to_delete+=("usb" "wpad" "hostapd")
#[[ $FIRMWARE_TAG != *"EMMC"* ]] && keywords_to_delete+=("samba" "autosamba" "jdcloud_ax1800-pro" "redmi_ax5-jdcloud")
[[ $FIRMWARE_TAG != *"EMMC"* ]] && keywords_to_delete+=("samba" "autosamba" "disk")
[[ $FIRMWARE_TAG == *"EMMC"* ]] && keywords_to_delete+=("cmiot_ax18" "qihoo_v6" "redmi_ax5=y" "zn_m2")

for keyword in "${keywords_to_delete[@]}"; do
    sed -i "/$keyword/d" ./.config
done

# Configuration lines to append to .config
provided_config_lines=(
    "CONFIG_PACKAGE_luci-app-zerotier=y"
    "CONFIG_PACKAGE_luci-i18n-zerotier-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-adguardhome=y"
    "CONFIG_PACKAGE_luci-i18n-adguardhome-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-poweroff=y"
    "CONFIG_PACKAGE_luci-i18n-poweroff-zh-cn=y"
    "CONFIG_PACKAGE_cpufreq=y"
    "CONFIG_PACKAGE_luci-app-cpufreq=y"
    "CONFIG_PACKAGE_luci-i18n-cpufreq-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-ttyd=y"
    "CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y"
    "CONFIG_PACKAGE_ttyd=y"
    "CONFIG_PACKAGE_luci-app-homeproxy=y"
    "CONFIG_PACKAGE_luci-i18n-homeproxy-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-ddns-go=y"
    "CONFIG_PACKAGE_luci-i18n-ddns-go-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-argon-config=y"
    "CONFIG_PACKAGE_nano=y"
    "CONFIG_BUSYBOX_CONFIG_LSUSB=n"
    "CONFIG_PACKAGE_luci-app-netspeedtest=y"
    "CONFIG_PACKAGE_luci-app-vlmcsd=y"
)

if [[ $FIRMWARE_TAG == *"NOWIFI"* ]]; then
    provided_config_lines+=(
        "CONFIG_PACKAGE_hostapd-common=n"
        "CONFIG_PACKAGE_wpad-openssl=n"
    )
else
    provided_config_lines+=(
        "CONFIG_PACKAGE_kmod-usb-net=y"
        "CONFIG_PACKAGE_kmod-usb-net-rndis=y"
        "CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y"
        "CONFIG_PACKAGE_usbutils=y"
    )
fi

[[ $FIRMWARE_TAG == *"EMMC"* ]] && provided_config_lines+=(
    "CONFIG_PACKAGE_luci-app-diskman=y"
    "CONFIG_PACKAGE_luci-i18n-diskman-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-docker=y"
    "CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-dockerman=y"
    "CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn=y"
    "CONFIG_PACKAGE_luci-app-alist=y"
    "CONFIG_PACKAGE_luci-i18n-alist-zh-cn=y"
    "CONFIG_PACKAGE_fdisk=y"
    "CONFIG_PACKAGE_parted=y"
    "CONFIG_PACKAGE_iptables-mod-extra=y"
    "CONFIG_PACKAGE_ip6tables-nft=y"
    "CONFIG_PACKAGE_ip6tables-mod-fullconenat=y"
    "CONFIG_PACKAGE_iptables-mod-fullconenat=y"
    "CONFIG_PACKAGE_libip4tc=y"
    "CONFIG_PACKAGE_libip6tc=y"
)

# Append configuration lines to .config
for line in "${provided_config_lines[@]}"; do
    echo "$line" >> .config
done

./scripts/feeds update -a
./scripts/feeds install -a

#修复文件
find ./ -name "getifaddr.c" -exec sed -i 's/return 1;/return 0;/g' {} \;
sed -i '/\/usr\/bin\/zsh/d' package/base-files/files/etc/profile

install -Dm755 "${GITHUB_WORKSPACE}/scripts/99_set_argon_primary.sh" "package/base-files/files/etc/uci-defaults/99_set_argon_primary"

