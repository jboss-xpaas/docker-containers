#!/bin/sh

# Program arguments
#
# -c | --container-name:    The name for the created container.
#                           If not specified, defaults to "xpaas-haproxy"
# -p | --root-password:     The root password
#                           If not specified, defaults to "xpaas"
# -host | --host-list:      The root password
#                           If not specified, defaults to "xpaas"
# -h | --help;              Show the script usage
#
# Example: sh start.sh -c "xpaas-haproxy" -p "mypass"

CONTAINER_NAME="xpaas-haproxy"
ROOT_PASSWORD="xpaas"
HA_HOSTS=""

function usage
{
    echo "usage: start.sh [[[-c <container_name> ] [-p <root_password>] [-hosts [<host_ip_one:host_port_one>]]] | [-h]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -c | --container-name ) shift
                                CONTAINER_NAME=$1
                                ;;
        -p | --root-password )  shift
                                ROOT_PASSWORD=$1
                                ;;
        -hosts | --hosts-list )   shift
                                HA_HOSTS=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

IMAGE_NAME="redhat/xpaas_haproxy"
IMAGE_TAG="1.0"

# Check if container is already started
if [ -f docker.pid ]; then
    echo "Container is already started"
    container_id=$(cat docker.pid)
    echo "Stoping container $container_id..."
    docker stop $container_id
    rm -f docker.pid
fi

# Start the xpaas-base-docker container
echo "Starting xpaas-base docker container using:"
echo "** Container name: $CONTAINER_NAME"
echo "** Root password: $ROOT_PASSWORD"
image_xpaas_haproxy=$(docker run -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" -e HA_HOSTS="$HA_HOSTS" $IMAGE_NAME:$IMAGE_TAG)
ip_xpaas_haproxy=$(docker inspect $image_xpaas_happroxy | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_haproxy > docker.pid

# End
echo ""
echo "Server started in $ip_xpaas_proxy"

exit 0