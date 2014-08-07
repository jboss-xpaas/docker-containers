#!/bin/bash

######################################################################################
# JBoss Application Server startup detection script
# This script waits for JBoss Application Server startup and run some custom scripts
# located at $STARTUP_DIRECTORY ( /jboss/scripts/jboss-appserver/startup )
# NOTE: This script run the custom startup scripts once JBoss EAP/Wildfly has started,
# before deploying web applications.
# NOTE: The scripts will be executed only once (at first container run).
######################################################################################

# Script arguments
# 1.- The directory where sh script files to execute after server startup are located.

# Check image argument to build.
if [ $# -ne 1 ]; then
  echo "Missing argument: startup directory."
  echo "Usage: ./jboss-startup-detection.sh /jboss/scripts/jboss-appserver/startup"
  exit 65
fi

STARTUP_DIRECTORY=$1

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Check if jboss appserver has been started.
# Do not check home page on HTTP port, as if server is started in domain mode with no hosts, this URL will never return a 200. So the check is done by trying to access to management HTTP interface.
IS_STARTED=$(curl --silent $DOCKER_IP:$JBOSS_MGMT_HTTP_PORT/management | grep html)
if [ "$IS_STARTED" == "" ]; then
    # Not started yet.
    echo "JBoss app-server not started yet. Retrying..."
    # Return 1 as exit code will produce supervisor daemon to re-execute this script until jboss app-server has been started (exit code = 0)
    exit 1
fi

# Jboss is started. Execute all related CLI and scripts.
echo "JBoss app-server is started. Running not previouly executed scripts in $STARTUP_DIRECTORY"
pushd .
cd $STARTUP_DIRECTORY
for script in *.sh
do
    if [ ! -f "$script.executed" ]; then
        echo "Running jboss custom startup script '$script'"
        ./$script
        # Mark this script as already executed, so do not execute it any more.
        touch "$script.executed"
    fi
done
popd

exit 0