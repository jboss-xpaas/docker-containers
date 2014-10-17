#!/bin/bash

##########################################################################################################
# This script deploy BPMS webapplications.
# - Deploy kie-wb
# - Deploy jbpm-dashbuilder
##########################################################################################################

echo "Starting JBoss BPMS deployment...."
 
# Deploy BPMS webapps
/jboss/scripts/jboss-appserver/jboss-cli.sh -f /jboss/scripts/bpms/bpms-deploy.cli

echo "End of JBoss BPMS deployment."

exit 0