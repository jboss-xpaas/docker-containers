#!/bin/sh


# Program arguments
#
# -cn | --cluster-name:     Cluster name
# -cvfs | --cluster-vfsrepo vfs-repo
# -h | --help help explanation
#
# Example: sh start.sh -c "xpaas-fabric8" -p "mypass"

CLUSTER_NAME="bpms-cluster"
VFS_REPO="vfs-repo"

function usage
{
    echo "usage: start.sh [[[-c <container_name> ] [-p <root_password>]] | [-h]]  -zServers [server.1=zServer1_IP:zooServer1_Port1:zooServer1_Port2\\\\nserver.2=zServer2_IP:zooServer2_Port1:zooServer2_Port2] [-cn <cluster_name>] [-cvfs <vfs-repo>] "
}

while [ "$1" != "" ]; do
    case $1 in
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

# ZOOKEEPER container
CONTAINER_NAME="xpaas-zookeeper"
ROOT_PASSWORD="xpaas"
ZSERVERS="#"
IMAGE_NAME="xpaas/xpaas_zookeeper"
IMAGE_TAG="1.0"

image_xpaas_zookeeper=$(docker run -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" -e CLUSTER_NAME="$CLUSTER_NAME" -e VFS_REPO="$VFS_REPO" $IMAGE_NAME:$IMAGE_TAG)
ip_xpaas_zookeeper=$(docker inspect $image_xpaas_base | grep IPAddress | awk '{print $2}' | tr -d '",')

ZOOKEEPER_CON=$ip_xpaas_zookeeper:2181



# NODE1 STANDALONE
IMAGE_NAME="xpaas/xpaas_bpms-eap"
IMAGE_TAG="1.0"
JBOSS_MODE="STANDALONE"
JBOSS_CONF_FILE="standalone-full-ha.xml"
CONTAINER_NAME="xpaas-host1-Node"
HOST_ID=HOST1


ALL_ARGUMENTS="--name $CONTAINER_NAME -e JBOSS_MODE=$JBOSS_MODE -e JBOSS_STANDALONE_CONF_FILE=\"$JBOSS_CONF_FILE\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e CLUSTER_NAME=\"$CLUSTER_NAME\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e HOST_ID=\"$HOST_ID\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e ZOOKEEPER_CON=\"$ZOOKEEPER_CON\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e VFS_REPO=\"$VFS_REPO\" "


image_xpaas_host1Node=$(docker run $CONTAINER_LINKING -P -d $ALL_ARGUMENTS $IMAGE_NAME:$IMAGE_TAG)
ip_host1Node=$(docker inspect $image_xpaas_host1Node | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_host1Node > dockerNode1.pid


# NODE2 STANDALONE
IMAGE_NAME="xpaas/xpaas_bpms-eap"
IMAGE_TAG="1.0"
JBOSS_MODE="STANDALONE"
JBOSS_CONF_FILE="standalone-full-ha.xml"
CONTAINER_NAME="xpaas-host2-Node"
HOST_ID=HOST2


ALL_ARGUMENTS="--name $CONTAINER_NAME -e JBOSS_MODE=$JBOSS_MODE -e JBOSS_STANDALONE_CONF_FILE=\"$JBOSS_CONF_FILE\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e CLUSTER_NAME=\"$CLUSTER_NAME\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e HOST_ID=\"$HOST_ID\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e ZOOKEEPER_CON=\"$ZOOKEEPER_CON\" "
ALL_ARGUMENTS="$ALL_ARGUMENTS  -e VFS_REPO=\"$VFS_REPO\" "


image_xpaas_host1Node=$(docker run $CONTAINER_LINKING -P -d $ALL_ARGUMENTS $IMAGE_NAME:$IMAGE_TAG)
ip_host2Node=$(docker inspect $image_xpaas_host2Node | grep IPAddress | awk '{print $2}' | tr -d '",')
echo $image_xpaas_host2Node > dockerNode2.pid




