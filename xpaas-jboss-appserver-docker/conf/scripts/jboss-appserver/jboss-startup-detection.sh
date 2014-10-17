#!/bin/bash

######################################################################################
# JBoss Application Server startup detection script
# This script waits for JBoss Application Server startup and run some custom scripts
######################################################################################

######################################################################################
# Script arguments
# 1.- The full path for callback script to execute.
######################################################################################

# Check callback script path argument.
if [ $# -ne 1 ]; then
  echo "Missing argument: callback shell script."
  echo "Usage: ./jboss-startup-detection.sh /jboss/scripts/jboss-appserver/script.sh"
  exit 65
fi

CALLBACK_SCRIPT=$1

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Check if jboss appserver has been started.
# The check is done by trying to access to management console interface.
# NOTE: Do not check home page on HTTP port, as if server is started in domain mode with no hosts, this URL will never return a 200. 
IS_STARTED=$(/opt/jboss-appserver/bin/jboss-cli.sh -c --controller=$DOCKER_IP:$JBOSS_MGMT_NATIVE_PORT --command=ls)
if [ "$IS_STARTED" == "" ]; then
    # Not started yet.
    echo "JBoss app-server not started yet. Retrying..."
    # Return 1 as exit code will produce supervisor daemon to re-execute this script until jboss app-server has been started (until exit code = 0)
    exit 1
fi

# Jboss is started.
echo "************************* JBoss **************************"
echo "                JBoss app-server is started. "
echo "**********************************************************"
echo "Running callback script located at '$CALLBACK_SCRIPT'"
$CALLBACK_SCRIPT

exit 0