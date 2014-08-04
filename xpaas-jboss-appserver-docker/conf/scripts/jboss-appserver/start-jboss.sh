#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script
# This script can be overriden in order to start the appserver with custom configurations
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

# Starts JBoss Application Server using $JBOSS_ARGUMENTS, specified when running the container, if any.
echo "Starting JBoss Application Server in address $JBOSS_BIND_ADDRESS:$JBOSS_HTTP_PORT / $JBOSS_BIND_ADDRESS:$JBOSS_HTTPS_PORT (SSL) and management in address $DOCKER_IP:$JBOSS_MGMT_HTTP_PORT / $DOCKER_IP:$JBOSS_MGMT_HTTPS_PORT"
/opt/jboss-appserver/bin/standalone.sh --server-config=$JBOSS_STANDALONE_CONF_FILE -b $JBOSS_BIND_ADDRESS -Djboss.http.port=$JBOSS_HTTP_PORT -Djboss.https.port=$JBOSS_HTTPS_PORT -Djboss.ajp.port=$JBOSS_AJP_PORT -Djboss.management.http.port=$JBOSS_MGMT_HTTP_PORT -Djboss.management.https.port=$JBOSS_MGMT_HTTPS_PORT -Djboss.bind.address.management=$DOCKER_IP $JBOSS_ARGUMENTS

exit 0