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

# 4. 强制升级 Golang 版本到 1.26+ (修复 xray-core 编译报错)
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang feeds/packages/lang/golang
