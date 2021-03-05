#!/bin/bash

# Exit on first error
set -eo pipefail

# Read input parameters
if [ $# -lt 1 ]; then
  echo "Usage:" $0 "(node name)"
  echo "Ex:" $0 "miner1"
  exit 1
fi

NODE_NAME=$1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)
source ${SCRIPT_DIR}/../common.sh

CONTAINER_NAME=bsc-${NODE_NAME}
DATA_ROOT=${SCRIPT_DIR}/../data/.ether-${NODE_NAME}
DATA_HASH=${SCRIPT_DIR}/../data/.ethash

mkdir -p ${DATA_ROOT} && mkdir -p ${DATA_HASH}

echo "Destroying old container ${CONTAINER_NAME}..."
docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true

if [ ! -z "${RPC_PORT}" ]; then
  RPC_ARG='--rpc --rpcaddr=0.0.0.0 --rpcport 8545 --rpcapi=db,eth,net,web3,personal --rpccorsdomain "*"'
  RPC_PORTMAP="-p ${RPC_PORT}:8545"
fi

BOOTNODE_URL="$(${SCRIPT_DIR}/get-bootnode-url.sh)"

if [ ! -d ${DATA_ROOT}/keystore ]; then
  echo "${DATA_ROOT}/keystore not found, running 'geth init'..."
  docker run --rm \
    -v ${DATA_ROOT}:/root/.ethereum \
    -v ${SCRIPT_DIR}/../data/genesis.json:/opt/genesis.json \
    ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} init /opt/genesis.json
  echo "...done!"
fi

echo "Running new container ${CONTAINER_NAME}..."
docker run -d --name ${CONTAINER_NAME} \
  --network ${DOCKER_NETWORK_NAME} \
  -v ${DATA_ROOT}:/root/.ethereum \
  -v ${DATA_HASH}:/root/.ethash \
  -v ${SCRIPT_DIR}/../data/genesis.json:/opt/genesis.json \
  ${RPC_PORTMAP} \
  ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} --networkid=${NETWORK_ID} ${RPC_ARG} \
    --cache=512 --verbosity=4 --maxpeers=3 --nodiscover --nousb ${@:2}

docker exec -ti ${CONTAINER_NAME} geth --exec "admin.addPeer(\"${BOOTNODE_URL}\")" attach > /dev/null
