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


#process .config file
sed -i '/usb/d' .config
sed -i '/passwall/d' .config
sed -i '/v2ray/d' .config
sed -i '/sing-box/d' .config
sed -i '/ddns/d' .config
sed -i '/SINGBOX/d' .config
#sed -i '/qihoo_v6/d' .config
sed -i '/redmi_ax5=y/d' .config
sed -i '/xiaomi_ax3600/d' .config
sed -i '/xiaomi_ax9000/d' .config
#sed -i '/jdc_ax1800-pro/d' .config
sed -i '/xiaomi_ax1800/d' .config
sed -i '/cmiot_ax18/d' .config


provided_config_lines=(
"CONFIG_PACKAGE_luci-app-ssr-plus=y"
"CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_libustream-openssl=y"
"CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Client=y"
"CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Rust_Server=y"
"CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray=y"
"CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ChinaDNS_NG=y"
"CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_MosDNS=y"
"CONFIG_PACKAGE_luci-i18n-ssr-plus-zh-cn=y"
"CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks_Simple_Obfs=y"
"CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Libev_Client=y"
"CONFIG_PACKAGE_luci-app-zerotier=y"
"CONFIG_PACKAGE_luci-i18n-zerotier-zh-cn=y"
"CONFIG_PACKAGE_luci-app-adguardhome=y"
"CONFIG_PACKAGE_luci-i18n-adguardhome-zh-cn=y"
"CONFIG_PACKAGE_luci-app-ddns-go=y"
"CONFIG_PACKAGE_luci-i18n-ddns-go-zh-cn=y"
)

# Path to the .config file
config_file_path=".config" 

# Append lines to the .config file
for line in "${provided_config_lines[@]}"; do
    echo "$line" >> "$config_file_path"
done


./scripts/feeds update -a
./scripts/feeds install -a
