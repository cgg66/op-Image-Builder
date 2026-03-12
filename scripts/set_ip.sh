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
# 确保网络配置正确
uci set network.lan.proto='static'
uci set network.lan.ipaddr='${LAN_IP}'
uci set network.lan.netmask='255.255.255.0'

# 尝试自动将所有 eth* 网口桥接到 LAN (针对 x86_64 特别有效)
ETH_DEVICES=\$(ls /sys/class/net | grep eth | xargs echo)
if [ -n "\$ETH_DEVICES" ]; then
    uci set network.lan.device='br-lan'
    uci set network.device.lan_dev=device
    uci set network.device.lan_dev.name='br-lan'
    uci set network.device.lan_dev.type='bridge'
    for dev in \$ETH_DEVICES; do
        uci add_list network.device.lan_dev.ports="\$dev"
    done
fi

uci commit network
EOF
chmod +x files/etc/uci-defaults/99-custom-ip
