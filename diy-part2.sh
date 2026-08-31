#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 1. 修改默认后台 IP
# 注意：这里必须使用双引号 (")，以确保 $ROUTER_IP 能被正确读取和替换
sed -i "s/192.168.1.1/$ROUTER_IP/g" package/base-files/files/bin/config_generate

# 2. 修改默认主机名
# 兼容处理：将源码默认的 OpenWrt 或 ImmortalWrt 替换为 $ROUTER_NAME
sed -i "s/hostname='OpenWrt'/hostname='$ROUTER_NAME'/g" package/base-files/files/bin/config_generate
sed -i "s/hostname='ImmortalWrt'/hostname='$ROUTER_NAME'/g" package/base-files/files/bin/config_generate

# 3. 修改默认主题 (可选)
# 将默认的 bootstrap 主题替换为更美观的 argon 主题
sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile
