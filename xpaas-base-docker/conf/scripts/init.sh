#!/bin/sh

# Welcome message
echo "Welcome to XPaaS Base docker container"

DOCKER_IP=$(ifconfig eth0 | egrep '([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $2}')
echo "export DOCKER_IP=$DOCKER_IP" >> /etc/profile
echo "Exported environemnt variable DOCKER_IP with value $DOCKER_IP"

exit $?