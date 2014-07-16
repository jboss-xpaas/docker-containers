#!/bin/bash

# Check if any jboss appserver (wildfly, eap) admin password is set in container runtime configuration.
if [[ -z "$JBOSS_APPSERVER_ADMIN_PASSWORD" ]] ; then
    echo "Not custom JBoss Application Server admin user password set. Using default password for admin user."
    export JBOSS_APPSERVER_ADMIN_PASSWORD="admin123!"
fi

# Configure the jboss appserver (wildfly, eap) admin password
echo "Using '$JBOSS_APPSERVER_ADMIN_PASSWORD' as JBoss Application Server admin password"
/opt/jboss-appserver/bin/add-user.sh admin $JBOSS_APPSERVER_ADMIN_PASSWORD --silent


# Starts JBoss Application Server
DOCKER_IP=$(/bin/sh /scripts/docker-ip.sh)

echo "Starting JBoss Application Server in HTTP address 0.0.0.0:8080 and management address $DOCKER_IP"
./opt/jboss-appserver/bin/standalone.sh -b 0.0.0.0 -Djboss.bind.address.management=$DOCKER_IP

exit $?