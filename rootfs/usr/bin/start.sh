#/bin/bash

set -euxo pipefail

# Trap signals and exit
trap "exit 0" SIGHUP SIGINT SIGTERM

ip link add dev br0 type bridge
ip link set dev eth0 master br0
ip link set br0 up

ip link add link br0 name br0.2 type vlan id 2
ip link add dev br-dtdlink type bridge
ip link set dev br0.2 master br-dtdlink
ip link set br0.2 up
ip link set br-dtdlink up

GW=$(ip route show default | awk '{ print $3 }')

IPV4_ADDRS=$(ip address show eth0 | grep 'inet ' | awk '{ print $2 }')
for IPV4_ADDR in $IPV4_ADDRS; do
    ip address add dev br0 $IPV4_ADDR
    ip address del dev eth0 $IPV4_ADDR
done
IPV6_ADDRS=$(ip address show eth0 | grep 'inet6 ' | awk '{ print $2 }')
for IPV6_ADDR in $IPV6_ADDRS; do
    # Make sure we don't add the link-local address
    if [[ $IPV6_ADDR == fe80:* ]]; then
        continue
    fi
    ip address add dev br0 $IPV6_ADDR
    ip address del dev eth0 $IPV6_ADDR
done

SUPERNODE=${SUPERNODE:-}
if [ -n "$SUPERNODE" ]; then
    ip route add blackhole 10.0.0.0/8 table 21
fi

ip address add dev br-dtdlink $NODE_IP/24

ip route add default via $GW dev br0

IS_DISABLE_VTUN=${DISABLE_VTUN:-0}
if [ "$IS_DISABLE_VTUN" -eq 1 ]; then
    rm -rf /etc/s6/vtund
fi

SERVER_NAME=${SERVER_NAME:-}
if [ -z "$SERVER_NAME" ]; then
    echo "No server name provided, exiting"
    exit 1
fi

SERVER_LON=${SERVER_LON:-}
if [ -z "$SERVER_LON" ]; then
    echo "No server longitude provided, exiting"
    exit 1
fi

SERVER_LAT=${SERVER_LAT:-}
if [ -z "$SERVER_LAT" ]; then
    echo "No server latitude provided, exiting"
    exit 1
fi

BABEL_DEBUG=${BABEL_DEBUG:-false}
if [ "$BABEL_DEBUG" == "true" ]; then
    echo "debug 1" >> /etc/babeld.conf
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
