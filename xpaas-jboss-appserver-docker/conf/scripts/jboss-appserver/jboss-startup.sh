#!/bin/bash

######################################################################################
# JBoss Application Server startup detection script
# This script waits for JBoss Application Server startup and run some custom scripts
# located at $STARTUP_DIRECTORY ( /jboss/scripts/jboss-appserver/startup )
# NOTE: This script run the custom startup scripts once JBoss EAP/Wildfly has started,
# before deploying web applications.
######################################################################################

# Script arguments
# 1.- The directory where sh script files to execute after server startup are located.

# Check image argument to build.
if [ $# -ne 1 ]; then
  echo "Missing argument: startup directory."
  echo "Usage: ./jboss-startup.sh /jboss/scripts/jboss-appserver/startup"
  exit 65
fi

STARTUP_DIRECTORY=$1

# Check if jboss appserver has been started.
IS_STARTED=$(curl --silent localhost:8080 | grep html)
if [ "$IS_STARTED" == "" ]; then
    # Not started yet.
    echo "JBoss app-server not started yet. Retrying..."
    # Return 1 as exit code will produce supervisor daemon to re-execute this script until jboss app-server has been started (exit code = 0)
    exit 1
fi

# Jboss is started. Execute all related CLI and scripts.
echo "JBoss app-server is started. Executing scripts in $STARTUP_DIRECTORY"
pushd .
cd $STARTUP_DIRECTORY
for script in *.sh
do
 echo "Running jboss custom startup script '$script'"
 ./$script
done
popd

exit 0