#!/bin/sh

# If /provisioned exists, then we've already run this script
if [ -f /provisioned ]; then
    exit 0
fi

echo 'yes' > /provisioned

# This is Ubuntu 22.04 LTS (Jammy)
apt update
apt upgrade -y
apt install -y docker.io

systemctl enable --now docker
systemctl disable --now snapd.service
systemctl disable --now snap.amazon-ssm-agent.amazon-ssm-agent.service

echo 'wireguard' >> /etc/modules-load.d/modules.conf
modprobe wireguard

# Add the ubuntu user to the Docker group
usermod -aG docker ubuntu

# Clone this repo
docker pull ghcr.io/usa-reddragon/aredn-virtual-node:main

docker network create --subnet=10.54.25.0/24 aredn-net

CH="http://${server_name}.local.mesh${extra_cors_hosts}"

if [[ "${supernode_zone}" != "" ]]; then
    # Add http://${server_name}.${supernode_zone}.mesh to the CH
    CH="$CH,http://${server_name}.${supernode_zone}.mesh"
fi

CH_SUPERNODE="http://${server_name}-supernode.local.mesh${extra_supernode_cors_hosts}"

if [[ "${supernode_zone}" != "" ]]; then
    # Add http://${server_name}.${supernode_zone}.mesh to the CH
    CH_SUPERNODE="$CH_SUPERNODE,http://${server_name}-supernode.${supernode_zone}.mesh"
fi

export NODE_IP_PLUS_1=$(echo ${node_ip} | awk -F. '{print $1"."$2"."$3"."$4+1}')

# Run the Docker image
docker run \
    --cap-add=NET_ADMIN \
    --privileged \
    -e PG_HOST='${pg_host}' \
    -e PG_USER='${pg_user}' \
    -e PG_PASSWORD='${pg_pass}' \
    -e PG_DATABASE='${pg_db}_supernode' \
    -e SESSION_SECRET='${session_secret}' \
    -e PASSWORD_SALT='${password_salt}' \
    -e CORS_HOSTS="$CH_SUPERNODE" \
    -e INIT_ADMIN_USER_PASSWORD='${init_admin_user_password}' \
    -e SERVER_NAME=${server_name}-SUPERNODE \
    -e NODE_IP=$NODE_IP_PLUS_1 \
    -e SERVER_LON='${server_lon}' \
    -e SERVER_LAT='${server_lat}' \
    -e DISABLE_MAP=1 \
    -e METRICS_PORT='9001' \
    -e TRUSTED_PROXIES='127.0.0.1' \
    -e SERVER_GRIDSQUARE=${server_gridsquare} \
    -e SUPERNODE=1 \
    -e SUPERNODE_ZONE=${supernode_zone} \
    -e VTUN_STARTING_ADDRESS=${vtun_starting_address_supernode} \
    --device /dev/net/tun \
    --name ${server_name}-SUPERNODE \
    --hostname ${server_name}-SUPERNODE \
    -p 5526:5525 \
    -d \
    --restart unless-stopped \
    --net aredn-net --ip $NODE_IP_PLUS_1 \
    ghcr.io/usa-reddragon/aredn-cloud-tunnel:main

docker run \
    --cap-add=NET_ADMIN \
    --privileged \
    -e PG_HOST='${pg_host}' \
    -e PG_USER='${pg_user}' \
    -e PG_PASSWORD='${pg_pass}' \
    -e PG_DATABASE='${pg_db}' \
    -e SESSION_SECRET='${session_secret}' \
    -e PASSWORD_SALT='${password_salt}' \
    -e CORS_HOSTS="$CH" \
    -e DISABLE_MAP=1 \
    -e INIT_ADMIN_USER_PASSWORD='${init_admin_user_password}' \
    -e SERVER_LON='${server_lon}' \
    -e SERVER_LAT='${server_lat}' \
    -e METRICS_PORT='9001' \
    -e TRUSTED_PROXIES='127.0.0.1' \
    -e SERVER_GRIDSQUARE=${server_gridsquare} \
    -e SERVER_NAME=${server_name} \
    -e WIREGUARD_TAP_ADDRESS=${wireguard_tap_address} \
    -e WIREGUARD_PEER_PUBLICKEY=${wireguard_peer_publickey} \
    -e WIREGUARD_SERVER_PRIVATEKEY=${wireguard_server_privatekey} \
    -e VTUN_STARTING_ADDRESS=${vtun_starting_address} \
    -e NODE_IP=${node_ip} \
    --device /dev/net/tun \
    --name ${server_name} \
    --hostname ${server_name} \
    -p 5525:5525 \
    -p 51820:51820/udp \
    -d \
    --restart unless-stopped \
    --net aredn-net --ip ${node_ip} \
    ghcr.io/usa-reddragon/aredn-cloud-tunnel:main

docker run \
    -d \
    --name watchtower \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --restart=unless-stopped \
    containrrr/watchtower \
    --cleanup \
    --interval 60

docker run \
    --network=container:${server_name} \
    --restart unless-stopped \
    -d \
    -v /:/host/root \
    -v /sys:/host/sys \
    -v /proc:/host/proc \
    --name node-exporter \
    -p 9100:9100 \
    quay.io/prometheus/node-exporter:latest \
    --path.procfs=/host/proc \
    --path.sysfs=/host/sys \
    --path.rootfs=/host/root \
    --path.udev.data=/host/root/run/udev/data \
    --web.listen-address=0.0.0.0:9100 \
    --collector.filesystem.mount-points-exclude='^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/.+)($|/)' \
    --collector.filesystem.fs-types-exclude='^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$'

docker run \
    --network=container:${server_name}-SUPERNODE \
    --restart unless-stopped \
    -d \
    -v /:/host/root \
    -v /sys:/host/sys \
    -v /proc:/host/proc \
    --name node-exporter \
    quay.io/prometheus/node-exporter:latest \
    --path.procfs=/host/proc \
    --path.sysfs=/host/sys \
    --path.rootfs=/host/root \
    --path.udev.data=/host/root/run/udev/data \
    --web.listen-address=0.0.0.0:9100 \
    --collector.filesystem.mount-points-exclude='^/(dev|proc|sys|var/lib/docker/.+|var/lib/kubelet/.+)($|/)' \
    --collector.filesystem.fs-types-exclude='^(autofs|binfmt_misc|bpf|cgroup2?|configfs|debugfs|devpts|devtmpfs|fusectl|hugetlbfs|iso9660|mqueue|nsfs|overlay|proc|procfs|pstore|rpc_pipefs|securityfs|selinuxfs|squashfs|sysfs|tracefs)$'
