# AREDN Virtual Node

[![Terraform](https://github.com/USA-RedDragon/aredn-cloud-tunnel/actions/workflows/terraform.yaml/badge.svg)](https://github.com/USA-RedDragon/aredn-cloud-tunnel/actions/workflows/terraform.yaml)

This project is intended to set up a "Cloud Tunnel" for the AREDN network. It acts like a node without any RF link capabilities. The purpose is to allow a large group of users to connect to a tunnel prior to RF deployments being rolled out.

This project requires Linux or WSL2 for the `/dev/net/tun` device

## Warning

It should be noted that in a disaster situation, it's likely that the internet will go out and this tunnel will be of no use.

## Environment Variables

Environment variables are used in order to generate the appropriate configuration files and to not save passwords.

|     Environment Variable      |                                  Purpose                                  |
| ----------------------------- | ------------------------------------------------------------------------- |
| `SERVER_NAME`                 | Provides the server name as seen in mesh status                           |
| `WIREGUARD_TAP_ADDRESS`       | The AREDN address to use for the WireGuard interface to tap into the mesh |
| `WIREGUARD_SERVER_PRIVATEKEY` | The private key of the WireGuard server                                   |
| `WIREGUARD_PEER_PUBLICKEY`    | The public key of the WireGuard peer                                      |

## How to use

This project runs in a Docker container. You can install Docker from here: <https://docs.docker.com/get-docker/>.

### Building the container

In the same directory as the `Dockerfile`:

```bash
docker build -t DESIRED_IMAGE_NAME .
```

Replace `DESIRED_IMAGE_NAME` with the desired image name. This will be used to run the container.

### Running the container

This container needs `--privileged` and `NET_ADMIN` in order to affect the routing tables and create tunnels.
The `--device /dev/net/tun` argument passes the host `tun` device into the container.

```bash
docker run --cap-add=NET_ADMIN --privileged --device /dev/net/tun --name DESIRED_NAME -p 5525:5525 -e SERVER_NAME="NOCALL-TEST" -e CONFIGURATION_JSON='{"clients":[{"name":"KI5VMF-MAIN","net":"172.31.180.16","pwd":"changeme"}]}' -d DESIRED_IMAGE_NAME
```

Replace `CONFIGURATION_JSON` with the configuration, `SERVER_NAME` with the desired name in the mesh status, `DESIRED_NAME` with the desired container name and `DESIRED_IMAGE_NAME` with the image name used when building.

### Viewing logs

```bash
docker logs DESIRED_NAME
```
