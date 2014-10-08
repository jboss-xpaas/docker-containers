#!/bin/bash

#################################################################################
# JBoss CLI script
# This script connects to the container JBoss server using Command Line Interface
#################################################################################

# Program arguments
#
# -c | --command:           The JBoss CLI command to execute
#                           OPTIONAL
# -f | --file:             The JBoss CLI file to execute
#                           OPTIONAL
# -h | --help;              Show the script usage
#

COMMAND=
FILE=

function usage
{
     echo "usage: start.sh [[[-c <cli_command> ] [-f <cli_file> ]] | [-h]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -c | --command )        shift
                                COMMAND=$1
                                ;;
        -f | --file )           shift
                                FILE=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Obtain the container IP address
DOCKER_IP=$(/bin/sh /jboss/scripts/docker-ip.sh)

# Connect to JBoss CLI using management IP as DOCKER_IP
if [[ ! -z $COMMAND ]]; then
    /opt/jboss-appserver/bin/jboss-cli.sh -c --controller=$DOCKER_IP:$JBOSS_MGMT_NATIVE_PORT --command="$COMMAND"
elif [ ! -z $FILE ]; then
    /opt/jboss-appserver/bin/jboss-cli.sh -c --controller=$DOCKER_IP:$JBOSS_MGMT_NATIVE_PORT --file="$FILE"
else
    /opt/jboss-appserver/bin/jboss-cli.sh -c --controller=$DOCKER_IP:$JBOSS_MGMT_NATIVE_PORT 
fi


exit $?