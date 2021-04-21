#!/bin/bash

# Exit on first error
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

# find . -type f -name "*.sh" -print0 | xargs -0 chmod 755

docker container stop $(docker container ls -aq) || true
docker container rm $(docker container ls -aq) || true

sudo rm -rf ${SCRIPT_DIR}/data

if ! docker images | grep bsc/client-go > /dev/null
then
  echo "Building source..."
  git clone https://github.com/binance-chain/bsc.git src
  docker build --tag bsc/client-go:v0.0.1 \
    --file ${SCRIPT_DIR}/src/Dockerfile ${SCRIPT_DIR}/src
  # docker build --tag bsc/client-go:alltools-v0.0.1 \
  #   --file ${SCRIPT_DIR}/src/Dockerfile.alltools ${SCRIPT_DIR}/src
fi

${SCRIPT_DIR}/scripts/start-bootnode.sh
echo "--------------------------------------------------"
${SCRIPT_DIR}/scripts/start-runnode.sh node1
echo "--------------------------------------------------"
${SCRIPT_DIR}/scripts/start-runnode.sh node2
echo "--------------------------------------------------"
${SCRIPT_DIR}/scripts/start-runnode.sh node3
echo "--------------------------------------------------"

sleep 5
${SCRIPT_DIR}/scripts/show-peers.sh node1
echo "--------------------------------------------------"
${SCRIPT_DIR}/scripts/show-peers.sh node2
echo "--------------------------------------------------"
${SCRIPT_DIR}/scripts/show-peers.sh node3
echo "--------------------------------------------------"

${SCRIPT_DIR}/scripts/start-miner.sh miner1 8545
echo "--------------------------------------------------"

sleep 5
${SCRIPT_DIR}/scripts/show-peers.sh miner1
echo "--------------------------------------------------"

docker ps -a