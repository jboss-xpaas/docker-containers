#!/bin/sh

##########################################################################
# JBoss Application Server startup script
# 1.- Configure admin passowrd
# 2.- Execute custom scripts in /jboss/scripts/jboss-appserver/init
# 3.- Start JBoss Application Server 
##########################################################################

# Check if any jboss appserver (wildfly, eap) admin password is set in container runtime configuration.
if [[ -z "$JBOSS_APPSERVER_ADMIN_PASSWORD" ]] ; then
    echo "Not custom JBoss Application Server admin user password set. Using default password for admin user."
    export JBOSS_APPSERVER_ADMIN_PASSWORD="admin123!"
fi

# Configure the jboss appserver (wildfly, eap) admin password
echo "Using '$JBOSS_APPSERVER_ADMIN_PASSWORD' as JBoss Application Server admin password"
/opt/jboss-appserver/bin/add-user.sh admin $JBOSS_APPSERVER_ADMIN_PASSWORD --silent

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Starts JBoss Application Server using $RUN_ARGUMENTS, specified when running the container, if any.
/jboss/scripts/jboss-appserver/start-jboss.sh $DOCKER_IP

exit $?