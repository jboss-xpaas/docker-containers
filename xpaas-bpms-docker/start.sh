#!/bin/sh

# Program arguments
#
# -i | --image:             The image to build. Possible values are: [bpms-wildfly,bpms-eap]
#                           If not specified, defaults to "bpms-wildfly"
# -c | --container-name:    The name for the created container.
#                           If not specified, defaults to "xpaas-wildfly" or "xpaas-eap" depending on image argument
# -p | --root-password:        The root password 
#                           If not specified, defaults to "xpaas"
# -ap | --admin-password:        The JBoss App Server admin user password 
#                           If not specified, defaults to "admin123!"
# -d | --connection-driver: The BPMS database connection driver 
#                           If not specified, defaults to "h2!"
# -url | --connection-url:  The BPMS database connection URL 
#                           If not specified, defaults to "jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
# -user | --connection-username:    The BPMS database connection username 
#                                   If not specified, defaults to "sa"
# -password | --connection-password:    The BPMS database connection password 
#                                       If not specified, defaults to "sa"
# -h | --help;              Show the script usage
#

CONTAINER_NAME="xpaas-wildfly"
ROOT_PASSWORD="xpaas"
JBOSS_APPSERVER_ADMIN_PASSWORD="admin123!"
IMAGE_NAME="xpaas/xpaas_bpms-wildfly"
IMAGE_TAG="1.0"
CONNECTION_DRIVER=h2
CONNECTION_URL="jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
CONNECTION_USERNAME=SA
CONNECTION_PASSWORD=SA

function usage
{
     echo "usage: start.sh [[[-i [bpms-wildfly,bpms-eap] ] [-c <container_name> ] [-p <root_password>] [-ap <admin_password>]] | [-h]]"
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

if [ ! "$2" == "bpms-eap" ] && [ ! "$2" == "bpms-wildfly" ]; then
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
                                JBOSS_APPSERVER_ADMIN_PASSWORD=$1
                                ;;
        -d | --connection-driver )  shift
                                CONNECTION_DRIVER=$1
                                ;;
        -url | --connection-url )  shift
                                CONNECTION_URL=$1
                                ;;
        -user | --connection-username )  shift
                                CONNECTION_USERNAME=$1
                                ;;
        -password | --connection-password )  shift
                                CONNECTION_PASSWORD=$1
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
echo "** JBoss Admin password: $JBOSS_APPSERVER_ADMIN_PASSWORD"
echo "** BPMS connection driver: $CONNECTION_DRIVER"
echo "** BPMS connection URL: $CONNECTION_URL"
echo "** BPMS connection username: $CONNECTION_USERNAME"
echo "** BPMS connection password: $CONNECTION_PASSWORD"
image_xpaas_wildfly=$(docker run -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" -e JBOSS_APPSERVER_ADMIN_PASSWORD="$JBOSS_APPSERVER_ADMIN_PASSWORD" -e BPMS_CONNECTION_URL="$CONNECTION_URL" -e BPMS_CONNECTION_DRIVER="$CONNECTION_DRIVER" -e BPMS_CONNECTION_USER="$CONNECTION_USERNAME" -e BPMS_CONNECTION_PASSWORD="$CONNECTION_PASSWORD" $IMAGE_NAME:$IMAGE_TAG)
ip_wildfly=$(docker inspect $image_xpaas_wildfly | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_wildfly > docker.pid

# End
echo "Installation of $CONTAINER_NAME docker image container finished"
echo ""
echo "Server starting in $ip_wildfly"

if [ $IMAGE_NAME == "xpaas/xpaas_bpms-eap" ]; then
    echo "The bpms is running at http://$ip_wildfly:8080/kie-wb-eap_6_1"

fi

if [ $IMAGE_NAME == "xpaas/xpaas_jbpm-wildfly" ]; then
    echo "The bpms is running at http://$ip_wildfly:8080/kie-wb-wildfly"
fi
