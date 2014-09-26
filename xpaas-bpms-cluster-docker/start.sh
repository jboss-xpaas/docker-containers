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
# -l | --link:              The docker "link" run argument. 
#                           If not set, not container linking is applied.
# -db | --database-name:    The name of the database to use when container is running linked with any database container. 
#                           If not set, defaults to "bpms"
# -h | --help;              Show the script usage
# -dh | domain-host         The domain controler information <contoller_host:contoller_port>]
#                           If not specified it means there isn't a domain controller
# -c_name | --cluster-name   The cluster name <cluster_name>
#                           If not specified the cluster work in standalone mode
# -c_host_id | --cluster-host_id The unic host id used to be identified at cluster <host_id_name>
#                           If not specified there
# -c_zoo_con | --cluster-zookeeper_con The connection to zookeeper server zookeeper_ip:zookeeper_port.
#                           If not specified there
# -cvfs | --cluster-vfsrepo vfs-repo
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
CONNECTION_DATABASE="bpms"
CONTAINER_LINKING=""

JBOSS_MODE="STANDALONE"
JBOSS_DOMAIN_CONTROLLER_IP=
JBOSS_DOMAIN_CONTROLLER_PORT=

CLUSTER_NAME="bpms-cluster"
HOST_ID="HOST1"
ZOOKEEPER_CON="172.17.0.2:2181"
VFS_REPO="vfs-repo"

# -cvfs | --cluster-vfsrepo vfs-repo

function usage
{
     echo "usage: start.sh [[[-i [bpms-wildfly,bpms-eap] ] [-c <container_name> ] [-p <root_password>] [-ap <admin_password>] [-l <container_linking>] [-db <external_db_name>]] | [-h]] [-dh <contoller_host:contoller_port>] -c_name <cluster_name> -c_host_id <host_id_name> -c_zoo_con <zookeeper_ip:zookeeper_port> [-cvfs <vfs-repo>]"
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
        -l | --link )           shift
                                CONTAINER_LINKING="--link $1"
                                ;;
        -db | --database-name )  shift
                                CONNECTION_DATABASE=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        -dh | --domain-host )   shift
                                JBOSS_MODE="DOMAIN-HOST"
                                JBOSS_DOMAIN_CONTROLLER=(${1/:/ })
                                JBOSS_DOMAIN_CONTROLLER_IP=${JBOSS_DOMAIN_CONTROLLER[0]}
                                JBOSS_DOMAIN_CONTROLLER_PORT=${JBOSS_DOMAIN_CONTROLLER[1]}
                                ;;
        -c_name | --cluster-name )  shift
                                CLUSTER_NAME=$1
                                ;;
        -c_host_id | --cluster-host_id )  shift
                                HOST_ID=$1
                                ;;
        -c_zoo_con | --cluster-zookeeper_con )  shift
                                ZOOKEEPER_CON=$1
                                ;;
        -cvfs | --cluster-vfsrepo )  shift
                                VFS_REPO=$1
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


# Start the xpaas docker container
echo "Starting $CONTAINER_NAME docker container using:"
echo "** Container name: $CONTAINER_NAME"
echo "** Root password: $ROOT_PASSWORD"
echo "** JBoss Admin password: $JBOSS_APPSERVER_ADMIN_PASSWORD"
echo "** BPMS connection driver: $CONNECTION_DRIVER"
echo "** BPMS connection URL: $CONNECTION_URL"
echo "** BPMS connection username: $CONNECTION_USERNAME"
echo "** BPMS connection password: $CONNECTION_PASSWORD"

ALL_ARGUMENTS="--name $CONTAINER_NAME -e JBOSS_MODE=$JBOSS_MODE "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e JBOSS_APPSERVER_ADMIN_PASSWORD=\"$JBOSS_APPSERVER_ADMIN_PASSWORD\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e ROOT_PASSWORD=\"$ROOT_PASSWORD\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e BPMS_CONNECTION_DRIVER=\"$CONNECTION_DRIVER\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e BPMS_CONNECTION_USER=\"$CONNECTION_USERNAME\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e BPMS_CONNECTION_PASSWORD=\"$CONNECTION_PASSWORD\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e BPMS_CONNECTION_URL=\"$CONNECTION_URL\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e BPMS_DATABASE=\"$CONNECTION_DATABASE\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e CLUSTER_NAME=\"$CLUSTER_NAME\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e HOST_ID=\"$HOST_ID\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e ZOOKEEPER_CON=\"$ZOOKEEPER_CON\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e VFS_REPO=\"$VFS_REPO\" "

if [ "$JBOSS_MODE" == "STANDALONE" ]; then
    ALL_ARGUMENTS="$ALL_ARGUMENTS  -e JBOSS_STANDALONE_CONF_FILE=\"$JBOSS_CONF_FILE\" "
elif [ "$JBOSS_MODE" == "DOMAIN" ]; then
    ALL_ARGUMENTS="$ALL_ARGUMENTS"
elif [ "$JBOSS_MODE" == "DOMAIN-HOST" ]; then
    ALL_ARGUMENTS="$ALL_ARGUMENTS  -e JBOSS_DOMAIN_MASTER_ADDR=$JBOSS_DOMAIN_CONTROLLER_IP -e JBOSS_DOMAIN_MASTER_PORT=$JBOSS_DOMAIN_CONTROLLER_PORT "
fi


image_xpaas_wildfly=$(docker run $CONTAINER_LINKING -P -d $ALL_ARGUMENTS $IMAGE_NAME:$IMAGE_TAG)
ip_wildfly=$(docker inspect $image_xpaas_wildfly | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_wildfly > docker.pid

# End
echo ""
echo "Server starting in $ip_wildfly"
echo "You can access the server root context in http://$ip_wildfly:8080"
echo "You can access the server HTTP administration console in http://$ip_wildfly:9990/console"
echo "The bpms is running at http://$ip_wildfly:8080/kie-wb"

exit 0