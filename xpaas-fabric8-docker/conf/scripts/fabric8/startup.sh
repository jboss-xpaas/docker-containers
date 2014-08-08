#!/bin/sh

# Welcome message
echo Welcome to fabric8: http://fabric8.io/
echo
echo Starting Fabric8 container: $FABRIC8_KARAF_NAME 
echo Connecting to ZooKeeper: $FABRIC8_ZOOKEEPER_URL using environment: $FABRIC8_FABRIC_ENVIRONMENT
echo Using bindaddress: $FABRIC8_BINDADDRESS

# Run fabric8 in server mode.
/opt/fabric8-karaf/bin/fabric8 server

exit 0