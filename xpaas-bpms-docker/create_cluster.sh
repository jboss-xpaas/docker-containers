#!/bin/sh

# **********************************************************************************************************
# Script information
# ------------------
# This script is used to run several BPMS instances in a clustered environment.
# The BPMS cluster environment consists of:
# - Several JBoss EAP/Wildfly instances with BPMS web application deployed (kie-wb & jbpm-dashbuilder)
# - An external existing database to share across all server instances
# - An external existing Zookeeper server up & running
# - An external existing Helix cluster and resource created in the Zookeeper server
# **********************************************************************************************************

# **********************************************************************************************************
# Program arguments
#
# -name | --cluster-name:           Cluster name
#                                   If not set defaults to "jbpm-cluster"
# -vfs | --vfs-lock:                The cluster vfs lock name
#                                   If not set defaults to "jbpm-vfs-repo"
# -n | --num-instances:             The number of server instances in the cluster. 
#                                   If not set defaults to "2"
# -zk | --zk-server:                The zookeeper server host and port, using format "<host>:<port>" 
#                                   If not set defaults to "127.0.0.1:2181"
# -db-url | --database-url:         The external database URL. 
# -db-driver | --database-driver:   The driver to use for the external database.
# -db-user | --database-user:       The database username
# -db-pwd| --database-password:     The database password
# -h | --help:                      Script usage
# **********************************************************************************************************

CLUSTER_NAME="bpms-cluster"
VFS_LOCK="jbpm-vfs-repo"
CLUSTER_INSTANCES=2
ZK_SERVER="127.0.0.1:2181"
DB_URL=""
DB_DRIVER=""
DB_USER=""
DB_PWD=""

function usage
{
    echo "usage: create_cluster.sh [ [-name <cluster_name] [-vfs <vfs_lock_name] [-n <num_instances] [-zk <zk_server] [-db-url <db_url] [-db-driver <db_driver] [-db-user <db_user] [-db-pwd <db_pwd] ]"
}

while [ "$1" != "" ]; do
    case $1 in
        -name | --cluster_name )    shift
                                    CLUSTER_NAME=$1
                                    ;;
        -vfs | --vfs-lock )         shift
                                    VFS_LOCK=$1
                                    ;;
        -n | --num-instances )      shift
                                    CLUSTER_INSTANCES=$1
                                    ;;
        -zk | --zk-server )         shift
                                    ZK_SERVER=$1
                                    ;;
        -db-url | --database-url )  shift
                                    DB_URL=$1
                                    ;;
        -db-driver | --database-driver) shift
                                        DB_DRIVER=$1
                                        ;;
        -db-user | --database-user)     shift
                                        DB_USER=$1
                                        ;;
        -db-pwd | --database-password)  shift
                                        DB_PWD=$1
                                        ;;
        -h | --help )               usage
                                    exit 1
                                    ;;
        * )                         usage
                                    exit 1
    esac
    shift
done



















# ***********************************************************************************************************
# ************************************************ NEUS CODE ************************************************
# ***********************************************************************************************************

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