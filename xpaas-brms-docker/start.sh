#!/bin/sh

# Program arguments
#
# -i | --image:             The image to build. Possible values are: [brms-wildfly,brms-eap]
#                           If not specified, defaults to "brms-wildfly"
# -c | --container-name:    The name for the created container.
#                           If not specified, defaults to "xpaas-wildfly" or "xpaas-eap" depending on image argument
# -p | --root-password:        The root password 
#                           If not specified, defaults to "xpaas"
# -ap | --admin-password:        The JBoss App Server admin user password 
#                           If not specified, defaults to "admin123!"
# -d | --connection-driver: The BRMS database connection driver
#                           If not specified, defaults to "h2!"
# -url | --connection-url:  The BRMS database connection URL
#                           If not specified, defaults to "jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
# -user | --connection-username:    The BRMS database connection username
#                                   If not specified, defaults to "sa"
# -password | --connection-password:    The BRMS database connection password
#                                       If not specified, defaults to "sa"
# -l | --link:              The docker "link" run argument. 
#                           If not set, not container linking is applied.
# -db | --database-name:    The name of the database to use when container is running linked with any database container. 
#                           If not set, defaults to "brms"
# -h | --help;              Show the script usage
#

CONTAINER_NAME="xpaas-brms"
ROOT_PASSWORD="xpaas"
JBOSS_APPSERVER_ADMIN_PASSWORD="admin123!"
IMAGE_NAME="redhat/xpaas_brms-wildfly"
IMAGE_TAG="1.0"
CONNECTION_DRIVER=h2
CONNECTION_URL="jdbc:h2:mem:test;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE"
CONNECTION_USERNAME=SA
CONNECTION_PASSWORD=SA
CONNECTION_DATABASE="brms"
CONTAINER_LINKING=""

function usage
{
     echo "usage: start.sh [[[-i [brms-wildfly,brms-eap] ] [-c <container_name> ] [-p <root_password>] [-ap <admin_password>] [-l <container_linking>] [-db <external_db_name>]] | [-h]]"
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

if [ ! "$2" == "brms-eap" ] && [ ! "$2" == "brms-wildfly" ]; then
    usage
    exit
fi

if [ ! "$2" == "bpms-wildfly" ]; then
   IMAGE_NAME="redhat/xpaas_brms_wildfly"
   CONTAINER_NAME="xpaas-brms-wildfly"
fi

while [ "$1" != "" ]; do
    case $1 in
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
        -l | --link )           shift
                                CONTAINER_LINKING="--link $1"
                                ;;
        -db | --database-name )  shift
                                CONNECTION_DATABASE=$1
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
echo "** BRMS connection driver: $CONNECTION_DRIVER"
echo "** BRMS connection URL: $CONNECTION_URL"
echo "** BRMS connection username: $CONNECTION_USERNAME"
echo "** BRMS connection password: $CONNECTION_PASSWORD"
image_xpaas_brms=$(docker run $CONTAINER_LINKING -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" -e JBOSS_APPSERVER_ADMIN_PASSWORD="$JBOSS_APPSERVER_ADMIN_PASSWORD" -e BRMS_CONNECTION_URL="$CONNECTION_URL" -e BRMS_CONNECTION_DRIVER="$CONNECTION_DRIVER" -e BRMS_CONNECTION_USER="$CONNECTION_USERNAME" -e BRMS_CONNECTION_PASSWORD="$CONNECTION_PASSWORD" -e BRMS_DATABASE="$CONNECTION_DATABASE" $IMAGE_NAME:$IMAGE_TAG)
ip_brms=$(docker inspect $image_xpaas_wildfly | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_brms > docker.pid

# End
echo ""
echo "Server starting in $ip_brms"
echo "You can access the server root context in http://$ip_brms:8080"
echo "You can access the server HTTP administration console in http://$ip_brms:9990/console"
echo "The brms is running at http://$ip_brms:8080/kie-drools-wb"

exit 0