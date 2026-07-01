source .env.db
source .env.network
source .env.volume  

if [ "$(docker ps -aq -f name=$DB_CONTAINER_NAME)" != "" ]; then
    echo "Container $DB_CONTAINER_NAME found"
    echo "Removing container $DB_CONTAINER_NAME"
    docker rm -f $DB_CONTAINER_NAME
else
    echo "Container $DB_CONTAINER_NAME not found"
fi


if [ "$(docker volume ls -q -f name=^${VOLUME_NAME}$)" != "" ]; then
     echo "Volume $VOLUME_NAME found"
     echo "Removing volume $VOLUME_NAME"
     docker volume rm $VOLUME_NAME
else
   echo "Volume $VOLUME_NAME not found"
fi

if [ "$(docker network ls -q -f name=^${NETWORK_NAME}$)" != "" ]; then
    echo "Network $NETWORK_NAME found"
    echo "Removing network $NETWORK_NAME"
    docker network rm $NETWORK_NAME
else
    echo "Network $NETWORK_NAME not found"
fi

