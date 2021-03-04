#!/bin/bash

# Exit on first error
set -eo pipefail

# Read input parameters
if [ $# -lt 1 ]; then
  echo "Usage:" $0 "(node name) (rpc port)"
  echo "Ex:" $0 "miner1 8545"
  exit 1
fi

NODE_NAME=$1
RPC_PORT=$2

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

ETHER_BASE="0x0000000000000000000000000000000000000001"

RPC_PORT=${RPC_PORT} ${SCRIPT_DIR}/start-runnode.sh ${NODE_NAME} --mine --minerthreads=1 --etherbase="${ETHER_BASE}"
