#!/bin/bash

# 修改默认IP
# sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# ============================================================
# 安装和更新软件包
# ============================================================
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4

	# 清理旧的包
	read -ra PKG_NAMES <<< "$PKG_NAME"
	for NAME in "${PKG_NAMES[@]}"; do
		find feeds/luci/ feeds/packages/ -maxdepth 3 -type d -iname "*$NAME*" -exec rm -rf {} + 2>/dev/null || true
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
			for NAME in "${PKG_NAMES[@]}"; do
				echo "moving $NAME"
				cp -rf $(find ./package/$REPO_NAME/*/ -maxdepth 3 -type d -iname "*$NAME*" -prune) ./package/
			done
			rm -rf ./package/$REPO_NAME/
			;;
		"name")
			mv -f ./package/$REPO_NAME ./package/$PKG_NAME
			;;
	esac
}


UPDATE_PACKAGE "luci-app-poweroff" "esirplayground/luci-app-poweroff" "master"
UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"
UPDATE_PACKAGE "openwrt-gecoosac" "ysuolmai/openwrt-gecoosac" "main"
#UPDATE_PACKAGE "luci-app-homeproxy" "immortalwrt/homeproxy" "master"
UPDATE_PACKAGE "luci-app-ddns-go" "sirpdboy/luci-app-ddns-go" "main"
UPDATE_PACKAGE "luci-app-openlist2" "sbwml/luci-app-openlist2" "main"

#small-package
UPDATE_PACKAGE "xray-core xray-plugin dns2tcp dns2socks haproxy hysteria \
        naiveproxy v2ray-core v2ray-geodata v2ray-geoview v2ray-plugin \
        tuic-client chinadns-ng ipt2socks tcping trojan-plus simple-obfs shadowsocksr-libev \
        luci-app-passwall smartdns luci-app-smartdns v2dat mosdns luci-app-mosdns \
        taskd luci-lib-xterm luci-lib-taskd luci-app-ssr-plus luci-app-passwall2 \
        luci-app-store quickstart luci-app-quickstart luci-app-istorex luci-app-cloudflarespeedtest \
        luci-theme-argon netdata luci-app-netdata lucky luci-app-lucky luci-app-openclash mihomo \
        luci-app-nikki luci-app-vlmcsd vlmcsd" "kenzok8/jell" "main" "pkg"

#speedtest
UPDATE_PACKAGE "luci-app-netspeedtest" "https://github.com/sbwml/openwrt_pkgs.git" "main" "pkg"
UPDATE_PACKAGE "speedtest-cli" "https://github.com/sbwml/openwrt_pkgs.git" "main" "pkg"

UPDATE_PACKAGE "luci-app-adguardhome" "https://github.com/ysuolmai/luci-app-adguardhome.git" "master"
UPDATE_PACKAGE "luci-app-tailscale" "asvow/luci-app-tailscale" "main"

UPDATE_PACKAGE "luci-app-quickfile" "https://github.com/sbwml/luci-app-quickfile" "main"

# ============================================================
# luci-app-diskman
# ============================================================
find feeds/luci/ feeds/packages/ -maxdepth 3 -type d -iname luci-app-diskman -exec rm -rf {} + 2>/dev/null || true
find feeds/luci/ feeds/packages/ -maxdepth 3 -type d -iname parted -exec rm -rf {} + 2>/dev/null || true
mkdir -p package/luci-app-diskman && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/applications/luci-app-diskman/Makefile -O package/luci-app-diskman/Makefile
sed -i 's/fs-ntfs /fs-ntfs3 /g' package/luci-app-diskman/Makefile
sed -i '/ntfs-3g-utils /d' package/luci-app-diskman/Makefile
mkdir -p package/parted && \
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -O package/parted/Makefile

UPDATE_PACKAGE "frp" "https://github.com/ysuolmai/openwrt-frp.git" "master"

# ============================================================
# 只保留指定的 qualcommax_ipq60xx 设备
# ============================================================
if [[ $FIRMWARE_TAG == *"EMMC"* ]]; then
    keep_pattern="\(redmi_ax5-jdcloud\|jdcloud_re-ss-01\|jdcloud_re-cs-07\)=y$"
else
    keep_pattern="\(redmi_ax5\|qihoo_360v6\|redmi_ax5-jdcloud\|zn_m2\|jdcloud_re-ss-01\|jdcloud_re-cs-07\)=y$"
fi

sed -i "/^CONFIG_TARGET_DEVICE_qualcommax_ipq60xx_DEVICE_/{
    /$keep_pattern/!d
}" ./.config

# ============================================================
# 删除不需要的关键词配置
# ============================================================
keywords_to_delete=(
    "uugamebooster" "luci-app-wol" "luci-i18n-wol-zh-cn" "CONFIG_TARGET_INITRAMFS" "ddns" "LSUSB" "mihomo"
    "smartdns" "kucat" "bootstrap"
)

#[[ $FIRMWARE_TAG == *"NOWIFI"* ]] && keywords_to_delete+=("usb" "wpad" "hostapd")
[[ $FIRMWARE_TAG != *"EMMC"* ]] && keywords_to_delete+=("samba" "autosamba" "disk")

for keyword in "${keywords_to_delete[@]}"; do
    sed -i "/$keyword/d" ./.config
done

# ============================================================
# 追加配置项
# ============================================================
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
    "CONFIG_COREMARK_OPTIMIZE_O3=y"
    "CONFIG_COREMARK_ENABLE_MULTITHREADING=y"
    "CONFIG_COREMARK_NUMBER_OF_THREADS=6"
    "CONFIG_PACKAGE_luci-app-filetransfer=y"
    "CONFIG_PACKAGE_openssh-sftp-server=y"
    "CONFIG_PACKAGE_luci-app-frpc=y"
    "CONFIG_OPKG_USE_CURL=y"
    "CONFIG_PACKAGE_opkg=y"
    "CONFIG_USE_APK=n"
    "CONFIG_PACKAGE_luci-app-tailscale=y"
    "CONFIG_PACKAGE_luci-app-gecoosac=y"
    "CONFIG_PACKAGE_luci-app-wireguard=y"
    "CONFIG_PACKAGE_wireguard-tools=y"
    "CONFIG_PACKAGE_kmod-wireguard=y"
)

DTS_PATH="./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"

if [[ $FIRMWARE_TAG == *"NOWIFI"* ]]; then
    provided_config_lines+=(
        "# CONFIG_PACKAGE_hostapd-common is not set"
        "# CONFIG_PACKAGE_wpad-openssl is not set"
        "# CONFIG_PACKAGE_wpad-full-openssl is not set"
        "# CONFIG_PACKAGE_wpad-basic-openssl is not set"
        "# CONFIG_PACKAGE_wpad is not set"
        "# CONFIG_PACKAGE_luci-app-cd8021x is not set"
        "# CONFIG_PACKAGE_static-neighbor-reports is not set"
        "# CONFIG_PACKAGE_hs20 is not set"
        "# CONFIG_PACKAGE_ieee8021xclient is not set"
    )


    echo "[NOWIFI] preparing nowifi dtsi files..."

    for dtsi in ipq6018-nowifi.dtsi ipq8074-nowifi.dtsi; do
        if [[ -f "${GITHUB_WORKSPACE}/scripts/$dtsi" ]]; then
            if [[ ! -f "$DTS_PATH/$dtsi" ]]; then
                cp "${GITHUB_WORKSPACE}/scripts/$dtsi" "$DTS_PATH/"
                echo "[NOWIFI] copied $dtsi to $DTS_PATH"
            else
                echo "[NOWIFI] $dtsi already exists in $DTS_PATH"
            fi
        else
            echo "[NOWIFI][ERROR] scripts/$dtsi not found!"
            exit 1
        fi
    done

    find "$DTS_PATH" -type f ! -iname '*nowifi*' -exec sed -i \
      -e '/#include "ipq6018.dtsi"/a #include "ipq6018-nowifi.dtsi"' \
      -e '/#include "ipq8074.dtsi"/a #include "ipq8074-nowifi.dtsi"' {} +

    echo "=== checking what depends on wpad ==="
    grep -r "wpad\|hostapd" feeds/ --include="Makefile" -l 2>/dev/null | head -20

    echo "qualcommax set up nowifi successfully!"

else
    provided_config_lines+=(
        "CONFIG_PACKAGE_kmod-usb-net=y"
        "CONFIG_PACKAGE_kmod-usb-net-rndis=y"
        "CONFIG_PACKAGE_kmod-usb-net-cdc-ether=y"
        "CONFIG_PACKAGE_usbutils=y"
        "CONFIG_PACKAGE_kmod-usb-acm=y"
        "CONFIG_PACKAGE_kmod-usb-ehci=y"
        "CONFIG_PACKAGE_kmod-usb-net-huawei-cdc-ncm=y"
        "CONFIG_PACKAGE_kmod-usb-net-rndis=y"
        "CONFIG_PACKAGE_kmod-usb-net-asix-ax88179=y"
        "CONFIG_PACKAGE_kmod-usb-net-rtl8152=y"
        "CONFIG_PACKAGE_kmod-usb-net-sierrawireless=y"
        "CONFIG_PACKAGE_kmod-usb-ohci=y"
        "CONFIG_PACKAGE_kmod-usb-serial-qualcomm=y"
        "CONFIG_PACKAGE_kmod-usb-storage=y"
        "CONFIG_PACKAGE_kmod-usb2=y"
    )
fi

if [[ "$FIRMWARE_TAG" != *"EMMC"* && "$FIRMWARE_TAG" == *"NOWIFI"* && "$FIRMWARE_TAG" != *"IPQ807X"* ]]; then
    sed -i 's/\s*kmod-[^ ]*usb[^ ]*\s*\\\?//g' ./target/linux/qualcommax/Makefile
    sed -i 's/\s*kmod-[^ ]*ath11k[^ ]*\s*\\\?//g' ./target/linux/qualcommax/Makefile
    echo "已删除 Makefile 中的 USB 相关 package"
fi

# 删除有问题的补丁文件
rm -f package/kernel/mac80211/patches/nss/ath11k/999-902-ath11k-fix-WDS-by-disabling-nwds.patch
rm -f package/kernel/mac80211/patches/nss/subsys/999-775-wifi-mac80211-Changes-for-WDS-MLD.patch
rm -f package/kernel/mac80211/patches/nss/subsys/999-922-mac80211-fix-null-chanctx-warning-for-NSS-dynamic-VLAN.patch

[[ $FIRMWARE_TAG == *"EMMC"* ]] && provided_config_lines+=(
    "CONFIG_PACKAGE_luci-app-docker=m"
    "CONFIG_PACKAGE_luci-i18n-docker-zh-cn=m"
    "CONFIG_PACKAGE_luci-app-dockerman=m"
    "CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn=m"
    "CONFIG_PACKAGE_luci-app-openlist2=y"
    "CONFIG_PACKAGE_luci-i18n-openlist2-zh-cn=y"
    "CONFIG_PACKAGE_iptables-mod-extra=y"
    "CONFIG_PACKAGE_ip6tables-nft=y"
    "CONFIG_PACKAGE_ip6tables-mod-fullconenat=y"
    "CONFIG_PACKAGE_iptables-mod-fullconenat=y"
    "CONFIG_PACKAGE_libip4tc=y"
    "CONFIG_PACKAGE_libip6tc=y"
    "CONFIG_PACKAGE_luci-app-passwall=y"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Client=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks_Libev_Server=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR_Libev_Client=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Simple_Obfs=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_SingBox=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=n"
    "CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray_Plugin=n"
    "CONFIG_PACKAGE_htop=y"
    "CONFIG_PACKAGE_tcpdump=y"
    "CONFIG_PACKAGE_openssl-util=y"
    "CONFIG_PACKAGE_qrencode=y"
    "CONFIG_PACKAGE_smartmontools-drivedb=y"
    "CONFIG_PACKAGE_usbutils=y"
    "CONFIG_PACKAGE_default-settings=y"
    "CONFIG_PACKAGE_default-settings-chn=y"
    "CONFIG_PACKAGE_iptables-mod-conntrack-extra=y"
    "CONFIG_PACKAGE_kmod-br-netfilter=y"
    "CONFIG_PACKAGE_kmod-ip6tables=y"
    "CONFIG_PACKAGE_kmod-ipt-conntrack=y"
    "CONFIG_PACKAGE_kmod-ipt-extra=y"
    "CONFIG_PACKAGE_kmod-ipt-nat=y"
    "CONFIG_PACKAGE_kmod-ipt-nat6=y"
    "CONFIG_PACKAGE_kmod-ipt-physdev=y"
    "CONFIG_PACKAGE_kmod-nf-ipt6=y"
    "CONFIG_PACKAGE_kmod-nf-ipvs=y"
    "CONFIG_PACKAGE_kmod-nf-nat6=y"
    "CONFIG_PACKAGE_kmod-dummy=y"
    "CONFIG_PACKAGE_kmod-veth=y"
    "CONFIG_PACKAGE_luci-app-frps=y"
    "CONFIG_PACKAGE_luci-app-samba4=y"
    "CONFIG_PACKAGE_luci-app-openclash=y"
)

[[ $FIRMWARE_TAG == "IPQ"* ]] && provided_config_lines+=("CONFIG_PACKAGE_sqm-scripts-nss=y")

# 写入配置
for line in "${provided_config_lines[@]}"; do
    echo "$line" >> .config
done

# ============================================================
# 删除有问题的补丁
# ============================================================
rm -f ./target/linux/qualcommax/patches-6.12/0083-v6.11-arm64-dts-qcom-ipq6018-add-sdhci-node.patch

# ============================================================
# 修复杂项
# ============================================================
find ./ -name "getifaddr.c" -exec sed -i 's/return 1;/return 0;/g' {} \;
sed -i '/\/usr\/bin\/zsh/d' package/base-files/files/etc/profile

find ./ -name "cascade.css" -exec sed -i 's/#5e72e4/#31A1A1/g; s/#483d8b/#31A1A1/g' {} \;
find ./ -name "dark.css" -exec sed -i 's/#5e72e4/#31A1A1/g; s/#483d8b/#31A1A1/g' {} \;
find ./ -name "cascade.less" -exec sed -i 's/#5e72e4/#31A1A1/g; s/#483d8b/#31A1A1/g' {} \;
find ./ -name "dark.less" -exec sed -i 's/#5e72e4/#31A1A1/g; s/#483d8b/#31A1A1/g' {} \;

install -Dm755 "${GITHUB_WORKSPACE}/scripts/99_ttyd-nopass.sh" "package/base-files/files/etc/uci-defaults/99_ttyd-nopass"
install -Dm755 "${GITHUB_WORKSPACE}/scripts/99_set_argon_primary.sh" "package/base-files/files/etc/uci-defaults/99_set_argon_primary"
install -Dm755 "${GITHUB_WORKSPACE}/scripts/99-distfeeds.conf" "package/emortal/default-settings/files/99-distfeeds.conf"

sed -i "/define Package\/default-settings\/install/a\\
\\t\$(INSTALL_DIR) \$(1)/etc\\n\
\t\$(INSTALL_DATA) ./files/99-distfeeds.conf \$(1)/etc/99-distfeeds.conf\n" "package/emortal/default-settings/Makefile"

sed -i "/exit 0/i\\
[ -f \'/etc/99-distfeeds.conf\' ] && mv \'/etc/99-distfeeds.conf\' \'/etc/opkg/distfeeds.conf\'\n\
sed -ri \'/check_signature/s@^[^#]@#&@\' /etc/opkg.conf\n" "package/emortal/default-settings/files/99-default-settings"

install -Dm755 "${GITHUB_WORKSPACE}/scripts/99_dropbear_setup.sh" "package/base-files/files/etc/uci-defaults/99_dropbear_setup"

# ============================================================
# 修复 cmake 版本兼容问题
# ============================================================
if ! grep -q "CMAKE_POLICY_VERSION_MINIMUM" include/cmake.mk; then
    echo 'CMAKE_OPTIONS += -DCMAKE_POLICY_VERSION_MINIMUM=3.5' >> include/cmake.mk
fi

# ============================================================
# 修复 rust 编译
# ============================================================
RUST_FILE=$(find ./feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
    sed -i 's/ci-llvm=true/ci-llvm=false/g' "$RUST_FILE"
    patch "$RUST_FILE" "${GITHUB_WORKSPACE}/scripts/rust-makefile.patch"
    echo "rust has been fixed!"
fi

# ============================================================
# 更新 Go 工具链到最新版本
# ============================================================
patch_openwrt_go() {
    local GO_MAKEFILE
    GO_MAKEFILE=$(find feeds -name "Makefile" | grep "lang/golang/golang/Makefile" | head -n 1)

    if [ -z "$GO_MAKEFILE" ]; then
        echo "❌ Error: Could not find OpenWrt Go Makefile!"
        return 1
    fi
    echo "Found go makefile: $GO_MAKEFILE"

    local LATEST_VER
    LATEST_VER="$(curl -s "https://go.dev/VERSION?m=text" | head -n 1 | tr -d '[:space:]' | sed 's/^go//')"

    if [ -z "$LATEST_VER" ]; then
        echo "❌ Error: Failed to fetch latest Go version."
        return 1
    fi

    local CUR_VER
    CUR_VER=$(grep "^PKG_VERSION:=" "$GO_MAKEFILE" | cut -d= -f2)
    echo "Current: $CUR_VER  →  Latest: $LATEST_VER"

    if [ "$CUR_VER" == "$LATEST_VER" ]; then
        echo "✅ Go version already up to date."
        return 0
    fi

    # 直接从官方获取 sha256，无需下载整个源码包
    echo "Fetching SHA256..."
    local NEW_HASH
    NEW_HASH=$(curl -sL "https://dl.google.com/go/go${LATEST_VER}.src.tar.gz.sha256")

    if [ -z "$NEW_HASH" ] || [ ${#NEW_HASH} -ne 64 ]; then
        echo "❌ Error: Failed to get SHA256 hash, falling back to download method..."
        NEW_HASH=$(curl -sL "https://go.dev/dl/go${LATEST_VER}.src.tar.gz" | sha256sum | awk '{print $1}')
        if [ -z "$NEW_HASH" ] || [ ${#NEW_HASH} -ne 64 ]; then
            echo "❌ Error: All hash methods failed."
            return 1
        fi
    fi

    echo "New Hash: $NEW_HASH"
    sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=$LATEST_VER/" "$GO_MAKEFILE"
    sed -i "s/^PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/" "$GO_MAKEFILE"

    grep -E "^PKG_VERSION|^PKG_HASH" "$GO_MAKEFILE"
    echo "✅ Go toolchain patched to $LATEST_VER successfully!"
}

patch_openwrt_go || exit 1
