#!/bin/bash

######################################################################################
# JBoss Application Server - Deploy hooks handler script
######################################################################################

DEPLOY_DIRECTORY=/jboss/scripts/jboss-appserver/deploy

# Deploy phase.
echo "Entering JBoss deploy phase..."

# Execute all related shell scripts (only once).
echo "Running not previouly executed scripts in '$DEPLOY_DIRECTORY'..."
pushd .
cd $DEPLOY_DIRECTORY
for script in *.sh
do
    if [ ! -f "$script.executed" ]; then
        echo "Running jboss custom deploy script '$script'"
        ./$script
        # Mark this script as already executed, so do not execute it any more.
        touch "$script.executed"
    fi
done
popd

exit 0