#!/bin/bash

# Exit on first error
set -euo pipefail

# Read input parameters
if [ $# -lt 1 ]; then
  echo "Usage:" $0 "(node name)"
  echo "Ex:" $0 "node1"
  exit 1
fi

NODE_NAME=$1

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

CONTAINER_NAME=ethereum-${NODE_NAME}

docker exec -ti "${CONTAINER_NAME}" geth --exec 'admin.peers' attach
