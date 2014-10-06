#!/bin/bash

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Configure the server node name.
echo "Configuring server node name with value '$JBOSS_NODE_NAME'"
/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/system-property=jboss.node.name:add(value=$JBOSS_NODE_NAME)"
/jboss/scripts/jboss-appserver/jboss-cli.sh -c '/subsystem=web:write-attribute(name=instance-id,value="${jboss.node.name}"'

# Configure the MySQL driver, if not already done.
# Not applicable for domain managed hosts.
if [ $JBOSS_MODE == "STANDALONE" ]; then
	echo "Creating mysql driver for standalone mode..."
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
elif [ $JBOSS_MODE == "DOMAIN" ]; then
    echo "Creating mysql driver for domain mode in all default profiles (default, full, full-ha, ha)..."
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/profile=default/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/profile=full/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/profile=full-ha/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/profile=ha/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
fi

echo "Reloading JBoss configuration..."
/jboss/scripts/jboss-appserver/jboss-cli.sh -c ":reload"
exit $?