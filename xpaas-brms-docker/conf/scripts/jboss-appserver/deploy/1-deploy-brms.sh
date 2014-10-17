#!/bin/bash

##########################################################################################################
# This script deploy BRMS webapplications.
# - Deploy kie-drools-wb
##########################################################################################################

echo "Starting JBoss BRMS deployment...."
 
# Deploy BRMS webapps
/jboss/scripts/jboss-appserver/jboss-cli.sh -f /jboss/scripts/brms/brms-deploy.cli

echo "End of JBoss BRMS deployment."

exit 0