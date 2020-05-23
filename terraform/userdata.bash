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
docker run --restart 'on-failure' --publish 443:443 --detach "$IMAGE"
