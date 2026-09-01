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

# 4. 修复 xray-core 编译报错 (终极无冲突方案)
# 清除 feeds 中所有的 xray-core 及其潜在干扰
find feeds/ -name "xray-core" -type d -exec rm -rf {} +

# 从 immortalwrt 23.05 稳定分支拉取 xray-core (完美兼容当前的 Golang 1.24)
git clone -b openwrt-23.05 --depth 1 https://github.com/immortalwrt/packages.git /tmp/packages

# 将其移动到 package/custom 目录下，确保最高编译优先级
mkdir -p package/custom
cp -r /tmp/packages/net/xray-core package/custom/

# 修复 Makefile 中的相对路径，将其指向正确的 feeds/packages/lang/ 目录
sed -i 's|../../lang/|$(TOPDIR)/feeds/packages/lang/|g' package/custom/xray-core/Makefile