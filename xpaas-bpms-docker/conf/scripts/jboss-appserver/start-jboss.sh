#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script for BPMS webapplication
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

# Starts JBoss Application Server using $JBOSS_APPSERVER_ARGUMENTS, specified when running the container, if any.
echo "Starting JBoss Application Server in HTTP address 0.0.0.0:8080 and management address $DOCKER_IP"
/opt/jboss-appserver/bin/standalone.sh --server-config=standalone-full.xml -b 0.0.0.0 -Djboss.bind.address.management=$DOCKER_IP -Djboss.bpms.connection_url="$BPMS_CONNECTION_URL" -Djboss.bpms.driver="$BPMS_CONNECTION_DRIVER" -Djboss.bpms.username="$BPMS_CONNECTION_USER" -Djboss.bpms.password="$BPMS_CONNECTION_PASSWORD" $JBOSS_APPSERVER_ARGUMENTS

exit 0