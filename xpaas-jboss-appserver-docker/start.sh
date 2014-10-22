#!/bin/sh

# Program arguments
#
# -i | --image:             The image to build. Possible values are: [wildfly,eap]
#                           If not specified, defaults to "wildfly"
# -c | --container-name:    The name for the created container.
#                           If not specified, defaults to "xpaas-wildfly" or "xpaas-eap" depending on image argument
# -p | --root-password:        The root password 
#                           If not specified, defaults to "xpaas"
# -name | --node-name:      The name for the JBoss server node. 
#                           If not specified, defaults to "node1"
# -ap | --admin-password:        The JBoss App Server admin user password 
#                           If not specified, defaults to "admin123!"
# -d | --domain:        The jboss container starts as a domain controller host. 
#
# -dh | --domain-host:      The jboss container starts as a domain host. 
#                           The domain controller management URL must be specified in format <IP>:<port> 
#
# -conf-file | --config-file:      The default config file when running in standalone mode. 
#                           If not specified, defaults to standalone.xml
#
# -args | --arguments:      The arguments for running JBoss server 
#                           If not specified, defaults to empty
# -h | --help;              Show the script usage
#

CONTAINER_NAME="xpaas-wildfly"
ROOT_PASSWORD="xpaas"
JBOSS_ADMIN_PASSWORD="admin123!"
JBOSS_NODE_NAME="node1"
IMAGE_NAME="redhat/xpaas-wildfly"
IMAGE_TAG="1.0"
JBOSS_CONF_FILE="standalone.xml"
RUN_ARGUMENTS=
JBOSS_MODE="STANDALONE"
JBOSS_DOMAIN_CONTROLLER_IP=
JBOSS_DOMAIN_CONTROLLER_PORT=
function usage
{
     echo "usage: start.sh [[[-i [wildfly,eap] ] [-c <container_name> ] [-p <root_password>] [-ap <admin_password>] [-d] [-dh <contoller_host:contoller_port> ] [-conf-file <conf_file> ] [-args <run_arguments> ]] | [-h]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -i | --image ) shift
                                IMAGE_NAME="redhat/xpaas-$1"
                                CONTAINER_NAME="xpaas-$1"
                                ;;
        -c | --container-name ) shift
                                CONTAINER_NAME=$1
                                ;;
        -p | --root-password )  shift
                                ROOT_PASSWORD=$1
                                ;;
        -ap | --admin-password )  shift
                                JBOSS_ADMIN_PASSWORD=$1
                                ;;
        -args | --arguments )  shift
                                RUN_ARGUMENTS=$1
                                ;;
        -name | --node-name )   shift
                                JBOSS_NODE_NAME=$1
                                ;;
        -conf-file | --config-file )  shift
                                JBOSS_CONF_FILE=$1
                                ;;
        -d | --domain )         JBOSS_MODE="DOMAIN"
                                ;;
        -dh | --domain-host )   shift
                                JBOSS_MODE="DOMAIN-HOST"
                                JBOSS_DOMAIN_CONTROLLER=(${1/:/ })
                                JBOSS_DOMAIN_CONTROLLER_IP=${JBOSS_DOMAIN_CONTROLLER[0]}
                                JBOSS_DOMAIN_CONTROLLER_PORT=${JBOSS_DOMAIN_CONTROLLER[1]}
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Perfom some domain configuration settings
if [ "$JBOSS_MODE" == "DOMAIN-HOST" ]; then
    if [[ -z "$JBOSS_DOMAIN_CONTROLLER_IP" ]] ; then
        echo "ERROR: Mode set to DOMAIN-HOST but no domain controller management IP specified."
        exit 1
    fi
    if [[ -z "$JBOSS_DOMAIN_CONTROLLER_PORT" ]] ; then
        echo "ERROR: Mode set to DOMAIN-HOST but no domain controller management port specified."
        exit 1
    fi
fi

# Check if container is already started
PID="docker-$CONTAINER_NAME.pid"
if [ -f $PID ]; then
    echo "Container is already started"
    container_id=$(cat $PID)
    echo "Stoping container $container_id..."
    docker stop $container_id
    rm -f $PID
fi

# Start the xpaas docker container
echo "Starting $CONTAINER_NAME docker container using:"
echo "** Container name: $CONTAINER_NAME"
echo "** Root password: $ROOT_PASSWORD"
echo "** JBoss Admin password: $JBOSS_ADMIN_PASSWORD"
echo "** JBoss run arguments: $RUN_ARGUMENTS"
echo "** JBoss server mode: $JBOSS_MODE"
if [ "$JBOSS_MODE" == "DOMAIN-HOST" ]; then
    echo "** JBoss domain controller address: $JBOSS_DOMAIN_CONTROLLER_IP"
    echo "** JBoss domain controller port: $JBOSS_DOMAIN_CONTROLLER_PORT"
fi

# Set all the environtment variables depending on jboss server mode.
ALL_ARGUMENTS="--name $CONTAINER_NAME -e JBOSS_MODE=$JBOSS_MODE "
if [ "$JBOSS_MODE" == "STANDALONE" ]; then
    ALL_ARGUMENTS="$ALL_ARGUMENTS  -e JBOSS_STANDALONE_CONF_FILE=\"$JBOSS_CONF_FILE\" "
elif [ "$JBOSS_MODE" == "DOMAIN" ]; then
    ALL_ARGUMENTS="$ALL_ARGUMENTS"
elif [ "$JBOSS_MODE" == "DOMAIN-HOST" ]; then
    ALL_ARGUMENTS="$ALL_ARGUMENTS  -e JBOSS_DOMAIN_MASTER_ADDR=$JBOSS_DOMAIN_CONTROLLER_IP -e JBOSS_DOMAIN_MASTER_PORT=$JBOSS_DOMAIN_CONTROLLER_PORT " 
fi
ALL_ARGUMENTS="$ALL_ARGUMENTS -e JBOSS_ARGUMENTS=\"$RUN_ARGUMENTS\" "
image_xpaas_wildfly=$(docker run -P -d -e ROOT_PASSWORD="$ROOT_PASSWORD" -e JBOSS_ADMIN_PASSWORD="$JBOSS_ADMIN_PASSWORD" -e JBOSS_NODE_NAME="$JBOSS_NODE_NAME" $ALL_ARGUMENTS $IMAGE_NAME:$IMAGE_TAG)
ip_wildfly=$(docker inspect $image_xpaas_wildfly | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_wildfly > $PID

# End
echo ""
echo "Server started in $ip_wildfly"
echo "You can access the server root context in http://$ip_wildfly:8080"
echo "You can access the server HTTP administration console in http://$ip_wildfly:9990/console"

exit 0