#!/bin/bash

# 修改默认IP
# sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}


#删掉垃圾源
sed -i "/kenzok8/d" "feeds.conf.default"
rm -rf package/feeds/small
rm -rf package/feeds/kenzo

# 添加额外插件
git clone --depth=1 https://github.com/kongfl888/luci-app-adguardhome package/luci-app-adguardhome
git clone --depth=1 https://github.com/esirplayground/luci-app-poweroff package/luci-app-poweroff

git clone https://github.com/gngpp/luci-theme-design.git  package/luci-theme-design

# 科学上网插件
git clone --depth=1 https://github.com/fw876/helloworld.git package/helloworld
#rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
#git clone https://github.com/sbwml/openwrt_helloworld package/luci-app-ssr-plus
git clone --depth=1 https://github.com/VIKINGYFY/homeproxy package/homeproxy

# Themes
#git clone --depth=1 -b 18.06 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge
#git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
#git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
#git clone --depth=1 https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom package/luci-theme-infinityfreedom
#git_sparse_clone main https://github.com/haiibo/packages luci-theme-atmaterial luci-theme-opentomcat luci-theme-netgear

# 更改 Argon 主题背景
#cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg


#DDNS-go
git clone https://github.com/sirpdboy/luci-app-ddns-go.git package/ddns-go

#luci-app-zerotier
git clone https://github.com/rufengsuixing/luci-app-zerotier.git package/luci-app-zerotier


# iStore
#git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
#git_sparse_clone main https://github.com/linkease/istore luci

# 在线用户
#git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
#sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
#sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
#chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

#tailscale
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile
git clone https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale



keywords_to_delete=(
#"passwall"
#"v2ray"
#"sing-box"
"ddns"
#"SINGBOX"
#"redmi_ax5=y"
"xiaomi_ax3600"
"xiaomi_ax9000"
"xiaomi_ax1800"
#"cmiot_ax18"
"glinet_gl-ax1800"
"glinet_gl-axt1800"
"jdcloud_ax6600"
"linksys_mr7350"
"uugamebooster"
"luci-app-wol"
"luci-i18n-wol-zh-cn"
#"luci-app-homeproxy"
"CONFIG_TARGET_INITRAMFS"
)

if [[ $FIRMWARE_TAG == *"NOWIFI"* ]]; then
  	keywords_to_delete+=("usb")
 	  keywords_to_delete+=("samba")
  	keywords_to_delete+=("autosamba")
fi

for line in "${keywords_to_delete[@]}"; do
    sed -i "/$line/d" ./.config
done

provided_config_lines=(
#"CONFIG_PACKAGE_luci-app-ssr-plus=y"
#"CONFIG_PACKAGE_luci-i18n-ssr-plus-zh-cn=y"
"CONFIG_PACKAGE_luci-app-zerotier=y"
"CONFIG_PACKAGE_luci-i18n-zerotier-zh-cn=y"
"CONFIG_PACKAGE_luci-app-adguardhome=y"
"CONFIG_PACKAGE_luci-i18n-adguardhome-zh-cn=y"
"CONFIG_PACKAGE_luci-app-ddns-go=y"
"CONFIG_PACKAGE_luci-i18n-ddns-go-zh-cn=y"
"CONFIG_PACKAGE_luci-app-poweroff=y"
"CONFIG_PACKAGE_luci-i18n-poweroff-zh-cn=y"
"CONFIG_PACKAGE_cpufreq=y"
"CONFIG_PACKAGE_luci-app-cpufreq=y"
"CONFIG_PACKAGE_luci-i18n-cpufreq-zh-cn=y"
"CONFIG_PACKAGE_luci-app-ttyd=y"
"CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y"
"CONFIG_PACKAGE_ttyd=y"
#"CONFIG_TARGET_INITRAMFS=n"
#"CONFIG_PACKAGE_luci-app-passwall=y"
#"CONFIG_PACKAGE_luci-i18n-passwall-zh-cn=y"
"CONFIG_PACKAGE_luci-app-homeproxy=y"
"CONFIG_PACKAGE_luci-i18n-homeproxy-zh-cn=y"
)

#if [[ $FIRMWARE_TAG != *"NOWIFI"* ]]; then
#  	provided_config_lines+=("CONFIG_PACKAGE_luci-app-diskman=y")
#  	provided_config_lines+=("CONFIG_PACKAGE_luci-i18n-luci-app-diskman=y")
#    provided_config_lines+=("CONFIG_PACKAGE_luci-app-docker=y")
#    provided_config_lines+=("CONFIG_PACKAGE_luci-i18n-docker-zh-cn=y")
#    provided_config_lines+=("CONFIG_PACKAGE_luci-app-dockerman=y")
#    provided_config_lines+=("CONFIG_PACKAGE_luci-i18n-dockerman-zh-cn=y")
#fi

# Path to the .config file
config_file_path=".config" 

# Append lines to the .config file
for line in "${provided_config_lines[@]}"; do
    echo "$line" >> "$config_file_path"
done


./scripts/feeds update -a
./scripts/feeds install -a

PKG_PATCH="$GITHUB_WORKSPACE/wrt/package/"

#预置HomeProxy数据
if [ -d *"homeproxy"* ]; then
	HP_RULES="surge"
	HP_PATCH="homeproxy/root/etc/homeproxy"

	chmod +x ./$HP_PATCH/scripts/*
	rm -rf ./$HP_PATCH/resources/*

	git clone -q --depth=1 --single-branch --branch "release" "https://github.com/Loyalsoldier/surge-rules.git" ./$HP_RULES/
	cd ./$HP_RULES/ && RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*")

	echo $RES_VER | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver
	awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt
	sed 's/^\.//g' direct.txt > china_list.txt ; sed 's/^\.//g' gfw.txt > gfw_list.txt
	mv -f ./{china_*,gfw_list}.{ver,txt} ../$HP_PATCH/resources/

	cd .. && rm -rf ./$HP_RULES/

	cd $PKG_PATCH && echo "homeproxy date has been updated!"
fi

rm -rf package/feeds/packages/shadowsocks-rust
cp -r package/helloworld/shadowsocks-rust package/feeds/packages/shadowsocks-rust
find ./ -name "getifaddr.c" -exec sed -i 's/return 1;/return 0;/g' {} \;
