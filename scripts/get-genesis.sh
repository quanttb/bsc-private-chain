#!/bin/bash

# Exit on first error
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)

GEN_NONCE="0x0000000000000042"
GEN_CHAIN_ID=13
GEN_ALLOC='"0x9A17bE5E06433182fe40695A3d14Aa744Fd845F7": {"balance": "100000000000000000000000"}'

sed "s/\${GEN_NONCE}/${GEN_NONCE}/g" ${SCRIPT_DIR}/../config/genesis.json.template | \
  sed "s/\${GEN_ALLOC}/${GEN_ALLOC}/g" | sed "s/\${GEN_CHAIN_ID}/${GEN_CHAIN_ID}/g" > ${SCRIPT_DIR}/../data/genesis.json
