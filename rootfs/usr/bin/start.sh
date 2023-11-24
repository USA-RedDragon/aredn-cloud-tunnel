#/bin/bash

# Trap signals and exit
trap "exit 0" SIGHUP SIGINT SIGTERM

ip address add dev eth0 $NODE_IP

/usr/bin/blockknownencryption

if [ -z "$SERVER_NAME" ]; then
    echo "No server name provided, exiting"
    exit 1
fi

if [ -z "$SERVER_LON" ]; then
    echo "No server longitude provided, exiting"
    exit 1
fi

if [ -z "$SERVER_LAT" ]; then
    echo "No server latitude provided, exiting"
    exit 1
fi

if ! [ -z "$WIREGUARD_TAP_ADDRESS" ]; then
    export WG_TAP_PLUS_1=$(echo $WIREGUARD_TAP_ADDRESS | awk -F. '{print $1"."$2"."$3"."$4+1}')

    ip link add dev wg0 type wireguard
    ip address add dev wg0 ${WIREGUARD_TAP_ADDRESS}/32

    mkdir -p /etc/wireguard/keys

    echo "${WIREGUARD_SERVER_PRIVATEKEY}" | tee /etc/wireguard/keys/server.key | wg pubkey > /etc/wireguard/keys/server.pub

    wg set wg0 peer ${WIREGUARD_PEER_PUBLICKEY} allowed-ips 10.0.0.0/8

    chmod 400 /etc/wireguard/keys/*

    wg set wg0 listen-port 51820 private-key /etc/wireguard/keys/server.key

    # Cross-VPN traffic OK
    iptables -A FORWARD -i wg0 -o wg0 -j ACCEPT

    iptables -t mangle -A PREROUTING -i wg0 -j MARK --set-mark 0x30
    iptables -t nat -A POSTROUTING ! -o wg0 -m mark --mark 0x30 -j MASQUERADE

    ip route add ${WG_TAP_PLUS_1}/32 dev wg0

    ip link set wg0 up
fi

# Run the AREDN manager
aredn-manager -d generate

# We need the syslog started early
rsyslogd -n &

cat <<EOF > /tmp/resolv.conf.auto
nameserver 127.0.0.11
options ndots:0
EOF

# Use the dnsmasq that's about to run
echo -e 'search local.mesh\nnameserver 127.0.0.1' > /etc/resolv.conf

exec s6-svscan /etc/s6
