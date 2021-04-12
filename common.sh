#!/bin/bash

# Exit on first error
set -eo pipefail

DOCKER_NETWORK_NAME=bsc
DOCKER_IMAGE_NAME=bsc/client-go
DOCKER_IMAGE_TAG=v0.0.1

BOOTNODE_PORT=30303
NETWORK_ID=13
