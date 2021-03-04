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

NETWORK_NAME=ethereum
CONTAINER_NAME=ethereum-${NODE_NAME}
# IMAGE_NAME=ethereum/client-go
# IMAGE_TAG=v1.8.12
IMAGE_NAME=bsc/client-go
IMAGE_TAG=v0.0.1
DATA_ROOT=${SCRIPT_DIR}/../data/.ether-${NODE_NAME}
DATA_HASH=${SCRIPT_DIR}/../data/.ethash

mkdir -p ${DATA_ROOT} && mkdir -p ${DATA_HASH}

echo "Destroying old container ${CONTAINER_NAME}..."
docker stop ${CONTAINER_NAME} || true
docker rm ${CONTAINER_NAME} || true

RPC_PORTMAP=
RPC_ARG=

if [ ! -z "${RPC_PORT}" ]; then
  RPC_ARG='--rpc --rpcaddr=0.0.0.0 --rpcport 8545 --rpcapi=db,eth,net,web3,personal --rpccorsdomain "*"'
  RPC_PORTMAP="-p ${RPC_PORT}:8545"
fi

BOOTNODE_URL=$(${SCRIPT_DIR}/get-bootnode-url.sh)

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
    ${IMAGE_NAME}:${IMAGE_TAG} init /opt/genesis.json
  echo "...done!"
fi

echo "Running new container ${CONTAINER_NAME}..."
docker run -d --name ${CONTAINER_NAME} \
  --network ethereum \
  -v ${DATA_ROOT}:/root/.ethereum \
  -v ${DATA_HASH}:/root/.ethash \
  -v ${SCRIPT_DIR}/../data/genesis.json:/opt/genesis.json \
  ${RPC_PORTMAP} \
  ${IMAGE_NAME}:${IMAGE_TAG} --bootnodes=${BOOTNODE_URL} ${RPC_ARG} --cache=512 --verbosity=4 --maxpeers=3 ${@:2}
