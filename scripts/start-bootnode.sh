#!/bin/bash

# Exit on first error
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

NETWORK_NAME=ethereum
CONTAINER_NAME=ethereum-bootnode
# IMAGE_NAME=ethereum/client-go
# IMAGE_TAG=alltools-v1.8.12
IMAGE_NAME=bsc/client-go
IMAGE_TAG=alltools-v0.0.1
DATA_ROOT=${SCRIPT_DIR}/../data
# BOOTNODE_SERVICE="127.0.0.1"

echo "Destroying old container ${CONTAINER_NAME}..."
docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true

# Generate bootnode key if needed
mkdir -p ${DATA_ROOT}/.bootnode
if [ ! -f ${DATA_ROOT}/.bootnode/boot.key ]; then
  echo "${DATA_ROOT}/.bootnode/boot.key not found, generating..."
  docker run --rm \
    -v ${DATA_ROOT}/.bootnode:/opt/bootnode \
    ${IMAGE_NAME}:${IMAGE_TAG} \
    bootnode --genkey /opt/bootnode/boot.key
  echo "...done!"
fi

# Creates ethereum network
[ ! "$(docker network ls | grep ethereum)" ] && docker network create ${NETWORK_NAME}
docker run -d --name ethereum-bootnode \
  -v ${DATA_ROOT}/.bootnode:/opt/bootnode \
  --network ${NETWORK_NAME} \
  ${IMAGE_NAME}:${IMAGE_TAG} \
  bootnode --nodekey /opt/bootnode/boot.key "$@"
