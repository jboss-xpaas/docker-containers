#!/bin/bash

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Configure the MySQL driver, if not already done.
EXIST_MYSQL_DRIVER=$(/opt/jboss-appserver/bin/jboss-cli.sh -c controller=$DOCKER_IP:9990 --command=/subsystem=datasources/data-source=mysql:read-resource | grep failed)
if [ ! "$EXIST_MYSQL_DRIVER" == "" ]; then
	echo "Creating mysql driver..."
	/opt/jboss-appserver/bin/jboss-cli.sh -c controller=$DOCKER_IP:9990 --command=/subsystem=datasources/jdbc-driver=mysql:add\(driver-name=mysql,driver-module-name=com.mysql\)
fi

exit $?