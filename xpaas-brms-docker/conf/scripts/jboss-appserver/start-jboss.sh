#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script for BRMS webapplication
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

# Starts JBoss Application Server using $JBOSS_APPSERVER_ARGUMENTS, specified when running the container, if any.
echo "Starting JBoss Application Server in HTTP address 0.0.0.0:8080 and management address $DOCKER_IP"
/opt/jboss-appserver/bin/standalone.sh --server-config=standalone-full.xml -b 0.0.0.0 -Djboss.bind.address.management=$DOCKER_IP -Djboss.brms.connection_url="$BRMS_CONNECTION_URL" -Djboss.brms.driver="$BRMS_CONNECTION_DRIVER" -Djboss.brms.username="$BRMS_CONNECTION_USER" -Djboss.brms.password="$BRMS_CONNECTION_PASSWORD" $JBOSS_APPSERVER_ARGUMENTS

exit 0