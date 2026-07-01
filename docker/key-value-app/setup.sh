# responsible for creating volumes and networks


source .env.volume
source .env.network

if [ "$(docker volume ls -q -f name=^${VOLUME_NAME}$)" != "" ]; then
    echo "Volume $VOLUME_NAME already exists"
else
    #create     volume
    docker volume create $VOLUME_NAME
fi

if [ "$(docker network ls -q -f name=^${NETWORK_NAME}$)" != "" ]; then
    echo "Network $NETWORK_NAME already exists"
else
    #create network
    docker network create $NETWORK_NAME
fi