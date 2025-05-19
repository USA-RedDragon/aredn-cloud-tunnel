#/bin/bash

set -euxo pipefail

# Trap signals and exit
trap "exit 0" SIGHUP SIGINT SIGTERM

ip link add dev br0 type bridge
ip link set dev eth0 master br0
ip link set br0 up

# br-lan, vlan 1
ip link add link br0 name br0.1 type vlan id 1
ip link add dev br-lan type bridge
ip link set dev br0.1 master br-lan
ip link set br0.1 up
ip link set br-lan up

# br-dtdlink, vlan 2
ip link add link br0 name br0.2 type vlan id 2
ip link add dev br-dtdlink type bridge
ip link set dev br0.2 master br-dtdlink
ip link set br0.2 up
ip link set br-dtdlink up

# br-wan, vlan 4
ip link add link br0 name br0.4 type vlan id 4
ip link add dev br-wan type bridge
ip link set dev br0.4 master br-wan
ip link set br0.4 up
ip link set br-wan up

GW=$(ip route show default | awk '{ print $3 }')

IPV4_ADDRS=$(ip address show eth0 | grep 'inet ' | awk '{ print $2 }')
for IPV4_ADDR in $IPV4_ADDRS; do
    ip address del dev eth0 $IPV4_ADDR
    ip address add dev br-wan $IPV4_ADDR
done
IPV6_ADDRS=$(ip address show eth0 | grep 'inet6 ' | awk '{ print $2 }')
for IPV6_ADDR in $IPV6_ADDRS; do
    # Make sure we don't add the link-local address
    if [[ $IPV6_ADDR == fe80:* ]]; then
        continue
    fi
    ip address del dev eth0 $IPV6_ADDR
    ip address add dev br-wan $IPV6_ADDR
done

ip route add default via $GW dev br-wan

SUPERNODE=${SUPERNODE:-}
if [ -n "$SUPERNODE" ]; then
    ip route add blackhole 10.0.0.0/8 table 21
fi

ip address add dev br-dtdlink $NODE_IP/8
# ip address add dev br-lan $LAN_IP/29

mkdir -p /etc/arednlink
echo "${NODE_IP} ${SERVER_NAME}" >> /etc/arednlink/hosts
touch /etc/arednlink/services

# Run the AREDN manager
aredn-manager generate

# We need the syslog started early
rsyslogd -n &

cat <<EOF > /tmp/resolv.conf.auto
nameserver 127.0.0.11
options ndots:0
EOF

# Use the dnsmasq that's about to run
echo -e 'search local.mesh\nnameserver 127.0.0.1' > /etc/resolv.conf

exec s6-svscan /etc/s6
