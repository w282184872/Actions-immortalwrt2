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

# 3. 修改默认主题 (可选)
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# 4. 修复 xray-core 编译报错 (终极版本号篡改法，绝对不冲突)
# 确保清理掉之前乱加的 custom 目录（如果在 Actions 里有残留的话）
rm -rf package/custom/xray-core

# 直接修改自带源码的版本号，从有 bug 的 1.8.3 升级到完美兼容老 Go 编译器的 1.8.24
sed -i 's/PKG_VERSION:=1.8.3/PKG_VERSION:=1.8.24/g' feeds/packages/net/xray-core/Makefile
sed -i 's/PKG_VERSION:=1.8.1/PKG_VERSION:=1.8.24/g' feeds/packages/net/xray-core/Makefile
sed -i 's/PKG_VERSION:=1.8.4/PKG_VERSION:=1.8.24/g' feeds/packages/net/xray-core/Makefile

# 强行跳过官方源码包的 SHA256 哈希值校验 (因为版本号变了，下载包的哈希也会变)
sed -i 's/PKG_HASH:=.*/PKG_HASH:=skip/g' feeds/packages/net/xray-core/Makefile