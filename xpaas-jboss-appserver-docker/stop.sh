#!/bin/sh
# Program arguments
#
# 1.- The docker container name to stop (mandatory)
 
# Check container name argument exists.
if [ $# -ne 1 ]; then
  echo "Missing argument: The docker container name to stop"
  echo "Usage: ./stop.sh <container_name>"
  exit 65
fi
 
CONTAINER_NAME=$1
PID="docker-$CONTAINER_NAME.pid"

# Check if container is already started
if [ -f $PID ]; then
    echo "Container is already started"
    container_id=$(cat $PID)
    echo "Stoping container $container_id..."
    docker stop $container_id
    rm -f $PID
fi

exit 0