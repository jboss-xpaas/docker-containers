#!/bin/sh

# Program arguments
#
# -c | --container-name:    The name for the created container.
#                           If not specified, defaults to "xpaas-fabric8"
# -p | --root-password:        The root password 
#                           If not specified, defaults to "xpaas"
# -h | --help;              Show the script usage
#
# Example: sh start.sh -c "xpaas-fabric8" -p "mypass"

CONTAINER_NAME="xpaas-fabric8"
ROOT_PASSWORD="xpaas"

function usage
{
    echo "usage: start.sh [[[-c <container_name> ] [-p <root_password>]] | [-h]]"
}

while [ "$1" != "" ]; do
    case $1 in
        -c | --container-name ) shift
                                CONTAINER_NAME=$1
                                ;;
        -p | --root-password )  shift
                                ROOT_PASSWORD=$1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

IMAGE_NAME="redhat/xpaas-fabric8"
IMAGE_TAG="1.0"

# Check if container is already started
if [ -f docker.pid ]; then
    echo "Container is already started"
    container_id=$(cat docker.pid)
    echo "Stoping container $container_id..."
    docker stop $container_id
    rm -f docker.pid
fi

# Start the xpaas-fabric8-docker container
echo "Starting xpaas-fabric8 docker container using:"
echo "** Container name: $CONTAINER_NAME"
echo "** Root password: $ROOT_PASSWORD"
image_xpaas_base=$(docker run -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" $IMAGE_NAME:$IMAGE_TAG)
ip_xpaas_base=$(docker inspect $image_xpaas_base | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_base > docker.pid

# End
echo ""
echo "Server started in $ip_xpaas_base"

exit 0