#!/bin/bash

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Configure the MySQL driver, if not already done.
# This configuration command must be done when running the container because the user can specify a different configuration rather than standalone.xml 
EXIST_MYSQL_DRIVER=$(/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/subsystem=datasources/jdbc-driver=mysql:read-resource" | grep failed)
if [ ! "$EXIST_MYSQL_DRIVER" == "" ]; then
	echo "Creating mysql driver..."
	/jboss/scripts/jboss-appserver/jboss-cli.sh -c "/subsystem=datasources/jdbc-driver=mysql:add(driver-name=mysql,driver-module-name=com.mysql)"
fi

exit $?