#!/bin/bash

##########################################################################################################
# This script configures BPMS as:
# - Modify WAR file -> persitence.xml (hibernate dialect)
# - Modify exsting "ExampleDS" datasource using expressions as value for some connection properties (CLI)
# - Apply security configurations (CLI)
# - Reaload JBoss configuration via (CLI)
# - Deploy WAR file (CLI)
#
# NOTE:  This configuration command must be done when running the container because the user 
# can specify a different configuration rather than standalone.xml
##########################################################################################################

echo "Starting JBoss BPMS web application configuration...."
 
# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# WAR file -> Add support for selected database (persitence.xml - hibernate dialect)
DEFAULT_DIALECT="org.hibernate.dialect.H2Dialect"
BPMS_WAR=/tmp/kie-wb.war
# TODO: Support for other database systems
if [ "$BPMS_CONNECTION_DRIVER" == "mysql" ]; then
    DIALECT="org.hibernate.dialect.MySQLDialect"
	echo "Configuring BPMS web application for MySQL database..."
	/jboss/scripts/bpms/change-hibernate-dialect.sh -war $BPMS_WAR -d "$DIALECT"
fi

# Server datasource configuration & security parameters
echo "Configuring server datasource & security parameters..."
/jboss/scripts/jboss-appserver/jboss-cli.sh -f /jboss/scripts/bpms/bpms.cli

# BPMS cluster configuration
if [[ ! -z "$BPMS_CLUSTER_NAME" ]] ; then
    echo "Configuring BPMS clustering parameters..."
    # Execute the cluster required CLI commands.
    /jboss/scripts/jboss-appserver/jboss-cli.sh -f /jboss/scripts/bpms/bpms-cluster.cli
fi

# Reload & Deploy webapps
/jboss/scripts/jboss-appserver/jboss-cli.sh -f /jboss/scripts/bpms/bpms-deploy.cli

echo "End of JBoss BPMS web application configuration."

exit 0