#!/bin/bash

######################################################################################
# JBoss Application Server - Configuration hooks handler script
######################################################################################

STARTUP_DIRECTORY=/jboss/scripts/jboss-appserver/startup

# Configuration phase.
echo "Entering JBoss configuration phase..."

# Execute all related shell scripts (only once).
echo "Running not previouly executed scripts in '$STARTUP_DIRECTORY'..."

pushd .
cd $STARTUP_DIRECTORY
for script in *.sh
do
    if [ ! -f "$script.executed" ]; then
        echo "Running jboss custom configuration script '$script'"
        ./$script
        # Mark this script as already executed, so do not execute it any more.
        touch "$script.executed"
    fi
done
popd

# After the configuration phase, perform a server reload to apply all configuration changes.
echo "Reloading JBoss configuration..."
/jboss/scripts/jboss-appserver/jboss-cli.sh -c "reload"
sleep 5

# Then, run the supervisor 'jboss-appserver-startup-deploy' program to deploy the webapps after the server reload have been completed.
echo "Running the JBoss deploy phase supervisor program"
supervisorctl start jboss-appserver-startup-detection-deploy

exit 0