#!/bin/bash
# scripts/set_ip.sh
# Usage: LAN_IP=192.168.1.1 ./scripts/set_ip.sh

if [ -z "${LAN_IP}" ]; then
    echo "LAN_IP is not set, skipping..."
    exit 0
fi

echo "Setting LAN IP to ${LAN_IP}..."
# Use uci-defaults for runtime configuration
mkdir -p files/etc/uci-defaults
cat > files/etc/uci-defaults/99-custom-ip <<EOF
# 设置管理地址
uci set network.lan.ipaddr='${LAN_IP}'

# 自动将所有物理网口桥接到 LAN (针对 x86)
# 如果系统有多个口，通常 eth0 是第一个口
uci set network.lan.device='br-lan'
uci set network.lan.proto='static'
uci set network.lan.netmask='255.255.255.0'

# 如果还没有桥接设备则创建
if ! uci get network.device_lan >/dev/null 2>&1; then
    uci set network.device_lan=device
    uci set network.device_lan.name='br-lan'
    uci set network.device_lan.type='bridge'
    uci set network.device_lan.ports='eth0'
fi

uci commit network
EOF
chmod +x files/etc/uci-defaults/99-custom-ip
