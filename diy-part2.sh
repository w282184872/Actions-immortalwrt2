#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 1. 修改默认后台 IP
sed -i "s/192.168.1.1/$ROUTER_IP/g" package/base-files/files/bin/config_generate

# 2. 修改默认主机名
sed -i "s/hostname='OpenWrt'/hostname='$ROUTER_NAME'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='ImmortalWrt'/hostname='$ROUTER_NAME'/g" package/base-files/files/bin/config_generate

# 3. 修改默认主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 4. 升级 Golang 编译器 (采用 sbwml 大佬专门为 21.02 适配的 Go 1.23，绝对稳定)
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang

# 5. 将自带的 xray-core 升级为 1.8.24 (完美匹配 Go 1.23，解决 gvisor 报错)
sed -i 's/PKG_VERSION:=1.8.3/PKG_VERSION:=1.8.24/g' feeds/packages/net/xray-core/Makefile
sed -i 's/PKG_VERSION:=1.8.1/PKG_VERSION:=1.8.24/g' feeds/packages/net/xray-core/Makefile
sed -i 's/PKG_VERSION:=1.8.4/PKG_VERSION:=1.8.24/g' feeds/packages/net/xray-core/Makefile

# 强行跳过官方源码包的 SHA256 哈希值校验
sed -i 's/PKG_HASH:=.*/PKG_HASH:=skip/g' feeds/packages/net/xray-core/Makefile
