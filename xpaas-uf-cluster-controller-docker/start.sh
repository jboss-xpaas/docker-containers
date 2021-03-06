#!/bin/sh

# Program arguments
#
# -c | --container-name:    The name for the created container.
#                           If not specified, defaults to "xpaas-fabric8"
# -p | --root-password:        The root password 
#                           If not specified, defaults to "xpaas"
# -h | --help;              Show the script usage
# -zServers | --zookeeperServers:  server.1=zoo1:2888:3888\\nserver.2=zoo2:2888:3888\\nserver.3=zoo3:2888:3888
#                           Other zookeeper server to ensure HA
# -cn | --cluster-name:     Cluster name
# -cvfs | --cluster-vfsrepo vfs-repo
#
# Example: sh start.sh -c "xpaas-fabric8" -p "mypass"

CONTAINER_NAME="xpaas-uf-cluster-controller"
ROOT_PASSWORD="xpaas"
ZSERVERS="#"
CLUSTER_NAME="bpms-cluster"
VFS_REPO="vfs-repo"


function usage
{
    echo "usage: start.sh [[[-c <container_name> ] [-p <root_password>]] | [-h]]  -zServers [server.1=zServer1_IP:zooServer1_Port1:zooServer1_Port2\\\\nserver.2=zServer2_IP:zooServer2_Port1:zooServer2_Port2] [-cn <cluster_name>] [-cvfs <vfs-repo>] "
}

while [ "$1" != "" ]; do
    case $1 in
        -c | --container-name ) shift
                                CONTAINER_NAME=$1
                                ;;
        -p | --root-password )  shift
                                ROOT_PASSWORD=$1
                                ;;
        -zServers | --zookeeperServers )  shift
                                        ZSERVERS=$1
                                        ;;
        -cn | --cluster_name )  shift
                                CLUSTER_NAME=$1
                                        ;;
        -cvfs | --cluster-vfsrepo )  shift
                                VFS_REPO=$1
                                        ;;

        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

IMAGE_NAME="redhat/xpaas-uf-cluster-controller"
IMAGE_TAG="1.0"

# Check if container is already started
if [ -f docker.pid ]; then
    echo "Container is already started"
    container_id=$(cat docker.pid)
    echo "Stoping container $container_id..."
    docker stop $container_id
    rm -f docker.pid
fi

# Start the xpaas-zookeeper-docker container
echo "Starting xpaas-zookeeper docker container using:"
echo "** Container name: $CONTAINER_NAME"
echo "** Root password: $ROOT_PASSWORD"
echo "** ZServers: $ZSERVERS"
echo "** ClusterName: $CLUSTER_NAME"
echo "** VFS_REPO: $VFS_REPO"
image_xpaas_base=$(docker run -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" -e ZOOKEEPER_REGISTERED_SERVERS="$ZSERVERS" -e CLUSTER_NAME="$CLUSTER_NAME" -e VFS_REPO="$VFS_REPO" $IMAGE_NAME:$IMAGE_TAG)
ip_xpaas_base=$(docker inspect $image_xpaas_base | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_base > docker.pid

# End
echo ""
echo "Server started in $ip_xpaas_base"

exit 0