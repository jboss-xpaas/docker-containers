#!/bin/bash

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Configure the MySQL driver, if not already done.
if [ $JBOSS_MODE == "STANDALONE" ]; then
	echo "Creating mysql driver for standalone mode..."
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
else
    echo "Creating mysql driver for domain mode in all default profiles (default, full, full-ha, ha)..."
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/profile=default/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/profile=full/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/profile=full-ha/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/profile=ha/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
fi

exit $?