#!/usr/bin/env bash

set -x
set -e
set -u
set -o pipefail

# TODO: verify this key and/or inline/pin it
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

apt update
apt install --yes \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt install --yes \
    docker-ce{,-cli} \
    containerd.io

# This comes from Terraform
# shellcheck disable=SC2016
IMAGE='${docker_image_name}'
docker run --detach --name private-relay \
    --restart 'unless-stopped' \
    --publish 443:443 \
    --sysctl net.ipv4.ip_local_port_range="1024 65535" \
    --sysctl net.ipv4.tcp_tw_reuse=1 \
    "$IMAGE"
docker run --detach --name watchtower \
    --volume /var/run/docker.sock:/var/run/docker.sock \
    containrrr/watchtower \
        --cleanup \
        --interval 300 \
        --stop-timeout 10s \
        private-relay
