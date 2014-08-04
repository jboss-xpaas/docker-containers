#!/bin/sh

# Program arguments
#
# -i | --image:             The image to build. Possible values are: [wildfly,eap]
#                           If not specified, defaults to "wildfly"
# -c | --container-name:    The name for the created container.
#                           If not specified, defaults to "xpaas-wildfly" or "xpaas-eap" depending on image argument
# -p | --root-password:        The root password 
#                           If not specified, defaults to "xpaas"
# -ap | --admin-password:        The JBoss App Server admin user password 
#                           If not specified, defaults to "admin123!"
# -conf-file | --config-file:      The default config file when running in standalone mode. 
#                           If not specified, defaults to standalone.xml
# -args | --arguments:      The arguments for running standalone.sh 
#                           If not specified, defaults to empty
# -h | --help;              Show the script usage
#

CONTAINER_NAME="xpaas-wildfly"
ROOT_PASSWORD="xpaas"
JBOSS_ADMIN_PASSWORD="admin123!"
IMAGE_NAME="xpaas/xpaas_wildfly"
IMAGE_TAG="1.0"
JBOSS_CONF_FILE="standalone.xml"
RUN_ARGUMENTS=

function usage
{
     echo "usage: start.sh [[[-i [wildfly,eap] ] [-c <container_name> ] [-p <root_password>] [-ap <admin_password>]  [-args <run_arguments> ]] | [-h]]"
}

if [ $# -ne 2 ]; then
  echo "Missing argument: starting docker container."
  usage
  exit 65
fi

if [ ! "$1" == "-i" ]; then
    usage
    exit
fi

if [ ! "$2" == "eap" ] && [ ! "$2" == "wildfly" ]; then
    usage
    exit
fi

while [ "$1" != "" ]; do
    case $1 in
        -i | --image ) shift
                                IMAGE_NAME="xpaas/xpaas_$1"
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
        -conf-file | --config-file )  shift
                                JBOSS_CONF_FILE=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done


# Check if container is already started
if [ -f docker.pid ]; then
    echo "Container is already started"
    container_id=$(cat docker.pid)
    echo "Stoping container $container_id..."
    docker stop $container_id
    rm -f docker.pid
fi

# Start the xpaas docker container
echo "Starting $CONTAINER_NAME docker container using:"
echo "** Container name: $CONTAINER_NAME"
echo "** Root password: $ROOT_PASSWORD"
echo "** JBoss Admin password: $JBOSS_ADMIN_PASSWORD"
echo "** JBoss run arguments: $RUN_ARGUMENTS"
image_xpaas_wildfly=$(docker run -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" -e JBOSS_ADMIN_PASSWORD="$JBOSS_ADMIN_PASSWORD" -e JBOSS_STANDALONE_CONF_FILE="$JBOSS_CONF_FILE" -e JBOSS_ARGUMENTS="$RUN_ARGUMENTS" $IMAGE_NAME:$IMAGE_TAG)
ip_wildfly=$(docker inspect $image_xpaas_wildfly | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_wildfly > docker.pid

# End
echo "Installation of $CONTAINER_NAME docker image container finished"
echo ""
echo "Server started in $ip_wildfly"

exit 0