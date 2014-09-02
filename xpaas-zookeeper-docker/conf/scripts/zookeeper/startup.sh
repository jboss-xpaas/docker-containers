#!/bin/sh

# Welcome message
echo Welcome to zookeeper
echo
echo Starting Zookeeper container: $ZOOKEEPER_NAME
echo Connecting to ZooKeeper: $ZOOKEEPER_URL using environment: $ZOOKEEPER_ENVIRONMENT
echo Using bindaddress: ZOOKEEPER_BINDADDRESS

# Run Zookeeper in server mode.
/opt/zookeeper/bin/zkServer.sh start

exit 0