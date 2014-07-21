#!/bin/bash

##########################################################################
# JBoss Application Server startup script
# 1.- Configure admin passowrd
# 2.- Execute custom scripts in /jboss/scripts/jboss-appserver/init
# 3.- Start JBoss Application Server 
##########################################################################

# Script arguments
# 1.- The JBoss CLI command to execute. 
#     OPTIONAL

COMMAND=

if [ ! "$1" == "" ]; then
    COMMAND="--command=$1"
fi

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Connect to JBoss CLI using management IP as DOCKER_IP
echo "/opt/jboss-appserver/bin/jboss-cli.sh -c --controller=$DOCKER_IP:9990 $COMMAND"
/opt/jboss-appserver/bin/jboss-cli.sh -c --controller=$DOCKER_IP:9990 $COMMAND

exit $?