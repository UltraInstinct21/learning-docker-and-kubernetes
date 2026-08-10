#!/bin/bash
# ==============================================================================
# SCRIPT: INFRASTRUCTURE SETUP (VOLUMES & NETWORKS)
# ==============================================================================
# Responsible for ensuring the Docker custom bridge network and named volume
# exist before starting application containers.
#
# WHY CUSTOM BRIDGE NETWORKS?
# - The default bridge network (`bridge`) does NOT support automatic DNS container discovery.
# - User-defined bridge networks (created via `docker network create`) provide:
#   1. Automatic DNS resolution by container name (e.g. backend reaches MongoDB via hostname `mongodb`).
#   2. Isolated communication scope between related containers.
# ==============================================================================

source .env.volume
source .env.network

# Check and create named volume for MongoDB persistent storage
if [ "$(docker volume ls -q -f name=^${VOLUME_NAME}$)" != "" ]; then
    echo "Volume $VOLUME_NAME already exists"
else
    echo "Creating Volume $VOLUME_NAME..."
    docker volume create $VOLUME_NAME
fi

# Check and create isolated bridge network
if [ "$(docker network ls -q -f name=^${NETWORK_NAME}$)" != "" ]; then
    echo "Network $NETWORK_NAME already exists"
else
    echo "Creating Network $NETWORK_NAME..."
    docker network create $NETWORK_NAME
fi