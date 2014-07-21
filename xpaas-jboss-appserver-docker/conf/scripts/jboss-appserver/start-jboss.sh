#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script
# This script can be overriden in order to start the appserver with custom configurations
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

# Starts JBoss Application Server using $JBOSS_APPSERVER_ARGUMENTS, specified when running the container, if any.
echo "Starting JBoss Application Server in HTTP address 0.0.0.0:8080 and management address $DOCKER_IP"
/opt/jboss-appserver/bin/standalone.sh -b 0.0.0.0 -Djboss.bind.address.management=$DOCKER_IP $JBOSS_APPSERVER_ARGUMENTS

exit 0