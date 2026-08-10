#!/bin/bash
# ==============================================================================
# SCRIPT: START BACKEND CONTAINER
# ==============================================================================
# Builds and runs the Express backend container:
# 1. Connects to MongoDB via network DNS hostname `mongodb`.
# 2. Mounts `./backend/src` via bind mount for hot-reloading code changes.
# 3. Connects to the same custom bridge network as the database.
# ==============================================================================

source .env.db
source .env.network
source setup.sh

LOCALHOST_PORT=3000
CONTAINER_PORT=3000

BACKEND_IMAGE_NAME=key-value-backend
BACKEND_CONTAINER_NAME=backend

# Hostname of the MongoDB container on the bridge network
MONGODB_HOST=mongodb

if [ -n "$(docker ps -q -f name=$BACKEND_CONTAINER_NAME)" ]; then
    echo "Container $BACKEND_CONTAINER_NAME already running"
    exit 1
fi

echo "Building backend image ($BACKEND_IMAGE_NAME)..."
docker build -t $BACKEND_IMAGE_NAME \
  -f backend/Dockerfile.dev \
  backend

echo "Starting backend container ($BACKEND_CONTAINER_NAME)..."
docker run --rm -d --name $BACKEND_CONTAINER_NAME \
  -e KEY_VALUE_DB=$KEY_VALUE_DB \
  -e KEY_VALUE_USER=$KEY_VALUE_USER \
  -e KEY_VALUE_PASSWORD=$KEY_VALUE_PASSWORD \
  -e PORT=$CONTAINER_PORT \
  -e MONGODB_HOST=$MONGODB_HOST \
  -p $LOCALHOST_PORT:$CONTAINER_PORT \
  -v ./backend/src:/app/src \
  --network $NETWORK_NAME \
  $BACKEND_IMAGE_NAME

echo "Backend is running on http://localhost:$LOCALHOST_PORT"
