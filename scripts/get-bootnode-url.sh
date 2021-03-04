#!/bin/bash

# Exit on first error
set -euo pipefail

# Reads current bootnode URL
ENODE_LINE=$(docker logs bsc-bootnode 2>&1 | grep enode | head -n 1)

# Replaces localhost by container IP
MY_IP=$(docker exec bsc-bootnode ifconfig eth0 | awk '/inet addr/{print substr($2,6)}')
ENODE_LINE=$(echo ${ENODE_LINE} | sed "s/127\.0\.0\.1/${MY_IP}/g" | sed "s/\[\:\:\]/${MY_IP}/g")

echo "enode:${ENODE_LINE#*enode:}"
