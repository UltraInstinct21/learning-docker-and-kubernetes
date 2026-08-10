#!/bin/bash
# ==============================================================================
# SCRIPT: CLEANUP SCRIPT (CONTAINERS, VOLUMES, NETWORKS)
# ==============================================================================
# Stops and removes all containers, named volumes, and bridge networks
# created during the key-value-app demonstration.
# ==============================================================================

source .env.db
source .env.network
source .env.volume  

# 1. Stop and remove database container
if [ "$(docker ps -aq -f name=$DB_CONTAINER_NAME)" != "" ]; then
    echo "Found container $DB_CONTAINER_NAME - removing..."
    docker rm -f $DB_CONTAINER_NAME
else
    echo "Container $DB_CONTAINER_NAME not found"
fi

# 2. Stop and remove backend container
if [ "$(docker ps -aq -f name=backend)" != "" ]; then
    echo "Found container backend - removing..."
    docker rm -f backend
else
    echo "Container backend not found"
fi

# 3. Remove named volume
if [ "$(docker volume ls -q -f name=^${VOLUME_NAME}$)" != "" ]; then
    echo "Found volume $VOLUME_NAME - removing..."
    docker volume rm $VOLUME_NAME
else
    echo "Volume $VOLUME_NAME not found"
fi

# 4. Remove custom bridge network
if [ "$(docker network ls -q -f name=^${NETWORK_NAME}$)" != "" ]; then
    echo "Found network $NETWORK_NAME - removing..."
    docker network rm $NETWORK_NAME
else
    echo "Network $NETWORK_NAME not found"
fi

echo "Cleanup complete!"
