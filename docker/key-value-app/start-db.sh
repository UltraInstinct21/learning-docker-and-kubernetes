#!/bin/bash
# ==============================================================================
# SCRIPT: START MONGODB DATABASE CONTAINER
# ==============================================================================
# Starts MongoDB Community Server container with:
# 1. Root & App credentials injected via environment variables.
# 2. Named volume mounted to `/data/db` for database persistence.
# 3. Read-only bind mount for `mongo-init.js` in `/docker-entrypoint-initdb.d/`
#    (automatically executed on first container initialization to create app user).
# 4. Attached to user-defined bridge network so backend can resolve it by name.
# ==============================================================================

MONGODB_IMAGE="mongodb/mongodb-community-server"
MONGODB_TAG="7.0-ubuntu2204"

source .env.db

# Root credentials
ROOT_USER="root-user"
ROOT_PASSWORD="root-password"

# Key-value database credentials
KEY_VALUE_DB="key-value-db"
KEY_VALUE_USER="key-value-user"
KEY_VALUE_PASSWORD="key-value-password"

# Connectivity
source .env.network
LOCALHOST_PORT="27018"
CONTAINER_PORT="27017"

# Storage
source .env.volume
VOLUME_CONTAINER_PATH="/data/db"

# Ensure volume and network exist
source setup.sh

if [ -n "$(docker ps -q -f name=$DB_CONTAINER_NAME)" ]; then
    echo "Container $DB_CONTAINER_NAME already running"
    exit 1
fi

echo "Starting MongoDB container ($DB_CONTAINER_NAME)..."
docker run --rm -d --name $DB_CONTAINER_NAME \
  -e MONGODB_INITDB_ROOT_USERNAME=$ROOT_USER \
  -e MONGODB_INITDB_ROOT_PASSWORD=$ROOT_PASSWORD \
  -e KEY_VALUE_DB=$KEY_VALUE_DB \
  -e KEY_VALUE_USER=$KEY_VALUE_USER \
  -e KEY_VALUE_PASSWORD=$KEY_VALUE_PASSWORD \
  -p $LOCALHOST_PORT:$CONTAINER_PORT \
  -v $VOLUME_NAME:$VOLUME_CONTAINER_PATH \
  -v ./db-config/mongo-init.js:/docker-entrypoint-initdb.d/mongo-init.js:ro \
  --network $NETWORK_NAME \
  $MONGODB_IMAGE:$MONGODB_TAG

echo "MongoDB is running on localhost:$LOCALHOST_PORT and container port $CONTAINER_PORT"
