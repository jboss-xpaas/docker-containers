#!/bin/bash

##########################################################################################################
# This script configures BRMS as:
# - Modify WAR file -> persitence.xml (hibernate dialect)
# - Modify exsting "ExampleDS" datasource using expressions as value for some connection properties (CLI)
# - Apply security configurations (CLI)
# - Reaload JBoss configuration via (CLI)
# - Deploy WAR file (CLI)
#
# NOTE:  This configuration command must be done when running the container because the user 
# can specify a different configuration rather than standalone.xml
##########################################################################################################

echo "Starting JBoss BRMS web application configuration...."
 
# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# WAR file -> Add support for selected database (persitence.xml - hibernate dialect)
DEFAULT_DIALECT="org.hibernate.dialect.H2Dialect"
BRMS_WAR=/tmp/kie-drools-wb.war
# TODO: Support for other database systems
if [ "$BRMS_CONNECTION_DRIVER" == "mysql" ]; then
    DIALECT="org.hibernate.dialect.MySQLDialect"
	echo "Configuring BRMS web application for MySQL database..."
	/jboss/scripts/brms/change-hibernate-dialect.sh -war $BRMS_WAR -d "$DIALECT"
fi

# Server datasource configuration & security parameters
echo "Configuring server datasource & security parameters..."
/jboss/scripts/jboss-appserver/jboss-cli.sh -f /jboss/scripts/brms/brms.cli

# Deploy BRMS webapp
# TODO: Deploy via CLI?
echo "Deploying BRMS webapp..."
cp -f /tmp/kie-drools-wb.war /opt/jboss-appserver/standalone/deployments/
touch /opt/jboss-appserver/standalone/deployments/kie-drools-wb.war.dodeploy


echo "End of JBoss BRMS web application configuration."

exit $?