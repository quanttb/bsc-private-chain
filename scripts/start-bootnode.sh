#!/bin/bash

# Exit on first error
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${SCRIPT_DIR}/../common.sh

CONTAINER_NAME=bsc-bootnode
DATA_ROOT=${SCRIPT_DIR}/../data/.ether-bootnode

mkdir -p ${DATA_ROOT}

echo "Destroying old container ${CONTAINER_NAME}..."
docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true

if [ ! -f ${SCRIPT_DIR}/../data/genesis.json ]; then
  echo "No genesis.json file found, generating..."
  ${SCRIPT_DIR}/get-genesis.sh
  echo "...done!"
fi

if [ ! -d ${DATA_ROOT}/keystore ]; then
  echo "${DATA_ROOT}/keystore not found, running 'geth init'..."
  docker run --rm \
    -v ${DATA_ROOT}:/root/.ethereum \
    -v ${SCRIPT_DIR}/../data/genesis.json:/opt/genesis.json \
    ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} init /opt/genesis.json
  echo "...done!"
fi

# Creates ethereum network
[ ! "$(docker network ls | grep ${DOCKER_NETWORK_NAME})" ] && docker network create ${DOCKER_NETWORK_NAME}

echo "Running new container ${CONTAINER_NAME}..."
docker run -d --name ${CONTAINER_NAME} \
  --network ${DOCKER_NETWORK_NAME} \
  -v ${DATA_ROOT}:/root/.ethereum \
  -v ${SCRIPT_DIR}/../data/genesis.json:/opt/genesis.json \
  ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} --networkid=${NETWORK_ID} \
    --port=${BOOTNODE_PORT} --nousb ${@:1}
