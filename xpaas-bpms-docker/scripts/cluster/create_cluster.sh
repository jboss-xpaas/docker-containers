#!/bin/sh

# **********************************************************************************************************
# Script information
# ------------------
# This script is used to run several BPMS instances in a clustered environment.
# The BPMS cluster environment consists of:
# - Several JBoss EAP/Wildfly instances with BPMS web application deployed (kie-wb & jbpm-dashbuilder)
# - A MySQL database to share across all server instances
# - A Zookeeper server up & running
# - A Helix cluster and resource created in the Zookeeper server
# Notes
# -----
# - The cluster is created using JBoss servers in standalone mode.
# **********************************************************************************************************

# **********************************************************************************************************
# Program arguments
#
# -name | --cluster-name:           Cluster name
#                                   If not set defaults to "bpms-cluster"
# -vfs | --vfs-lock:                The cluster vfs lock name
#                                   If not set defaults to "bpms-vfs-lock"
# -n | --num-instances:             The number of server instances in the cluster 
#                                   If not set defaults to "2"
# -db-root-pwd:                     The root password for the MySQL database
#                                   If not set defaults to "mysql"
# -h | --help:                      Script usage
# **********************************************************************************************************

CLUSTER_NAME="bpms-cluster"
VFS_LOCK="bpms-vfs-lock"
CLUSTER_INSTANCES=2
ZK_HOST=
ZK_PORT=2181
ZK_IMAGE_NAME="redhat/xpaas_zookeeper"
ZK_IMAGE_VERSION="1.0"
MYSQ_IMAGE_NAME="mysql"
MYSQ_IMAGE_VERSION="5.6"
MYSQL_CONTAINER_IP=
MYSQL_CONTAINER_PORT=3306
MYSQL_DB_NAME="bpmsclustering"
MYSQL_ROOT_PWD="mysql"
MYSQ_DB_URL=
QUARTZ_MYSQL_SCRIPT=quartz_tables_mysql.sql
BPMS_IMAGE_NAME="redhat/xpaas_bpms-eap"
BPMS_IMAGE_VERSION="1.0"
BPMS_CONTAINER_IP=
HAPROXY_IMAGE_NAME="redhat/xpaas_haproxy"
HAPROXY_IMAGE_VERSION="1.0"
HAPROXY_CONTAINER_IP=
HA_HOSTS=""
BPMS_CURRENT_NODE_IP=""

# *************************************************************************************************************
# Usage function
# *************************************************************************************************************
function usage
{
    echo "usage: create_cluster.sh [ [-name <cluster_name>] [-vfs <vfs_lock_name>] [-n <num_instances>] [-zk <zk_server>] [-db-url <db_url>] [-db-driver <db_driver>] [-db-user <db_user>] [-db-pwd <db_pwd>] ]"
}

# *************************************************************************************************************
# HAproxy
# *************************************************************************************************************
function run_haproxy() {

    echo "*************************************************************************************************************"
    echo "HAproxy"
    echo "*************************************************************************************************************"

    # Create the HAproxy container.
    CONTAINER_NAME="bpms-haproxy"
    ROOT_PASSWORD="xpaas"
    echo "hahosts: $HA_HOSTS"
    image_xpaas_haproxy=$(docker run -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" -e HA_HOSTS="$HA_HOSTS" $HAPROXY_IMAGE_NAME:$HAPROXY_IMAGE_TAG)
    HAPROXY_CONTAINER_IP=$(docker inspect $image_xpaas_haproxy | grep IPAddress | awk '{print $2}' | tr -d '",')
    echo "HAProxy - Container started at $HAPROXY_CONTAINER_IP:5000"

    echo ""
    echo ""
}

# *************************************************************************************************************
# Zookeeper / Helix
# *************************************************************************************************************
function run_zk_helix() {

    echo "*************************************************************************************************************"
    echo "Zookeeper / Helix"
    echo "*************************************************************************************************************"
    
    # Create the BPMS container.
    CONTAINER_NAME="bpms-zookeeper"
    ROOT_PASSWORD="xpaas"
    image_xpaas_zookeeper=$(docker run -P -d --name $CONTAINER_NAME -e ROOT_PASSWORD="$ROOT_PASSWORD" -e CLUSTER_NAME="$CLUSTER_NAME" -e VFS_REPO="$VFS_LOCK" $ZK_IMAGE_NAME:$ZK_IMAGE_VERSION)
    ZK_HOST=$(docker inspect $image_xpaas_zookeeper | grep IPAddress | awk '{print $2}' | tr -d '",')
    echo "Zookeeper - Container started at $ZK_HOST:2181"
    
    echo ""
    echo ""
}

# *************************************************************************************************************
# Initialization & checks
# *************************************************************************************************************
function init() {
    echo "*************************************************************************************************************"
    echo "Initialization & checks"
    echo "*************************************************************************************************************"
    
    # Currently there are no mandatory script arguments, all the arguments have default values.
    
    # Check mysql client is installed
    echo "Checking if MySQL client is installed..."
    if which mysql >/dev/null; then
        echo "MySQL client detected!"
    else
        echo "MySQL client NOT detected. Exiting!"
        exit 1
    fi
    
    echo ""
    echo ""
}

# *************************************************************************************************************
# MySQL Database
# *************************************************************************************************************
function run_mysql() {
    echo "*************************************************************************************************************"
    echo "Database"
    echo "*************************************************************************************************************"
    
    # Create the MySQL container.
    mysql_container_id=$(docker run --name bpms-mysql -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PWD -P -d $MYSQ_IMAGE_NAME:$MYSQ_IMAGE_VERSION)
    MYSQL_CONTAINER_IP=$(docker inspect $mysql_container_id | grep IPAddress | awk '{print $2}' | tr -d '",')
    echo "MySQL - Container started at $MYSQL_CONTAINER_IP with the following credentials: root / $MYSQL_ROOT_PWD"

    # Setting the database JDBC URL.
    MYSQ_DB_URL="jdbc:mysql://$MYSQL_CONTAINER_IP:3306/$MYSQL_DB_NAME"
    echo "MySQL -The JDBC URL for the database is '$MYSQ_DB_URL'"

    # TODO: Improve by waiting unitl port 3306 is available. (Including a timeout if startup fails)
    echo "MySQL - Waiting for port 3306 available..."
    sleep 15
    
    # Import the quartz tables required for clustering.
    echo "MySQL - Creating database '$MYSQL_DB_NAME'"
    mysql -u root -p$MYSQL_ROOT_PWD --host=$MYSQL_CONTAINER_IP --execute="create database $MYSQL_DB_NAME;"

    # TODO: The docker network IP should NOT be a hardcoded one. It depedens on each docker daemon configuration.
    MYSQL_GRANT_IPS="172.17.%.%"
    MYSQL_GRANT_QUERY="GRANT ALL PRIVILEGES ON $MYSQL_DB_NAME.* TO 'root'@'$MYSQL_GRANT_IPS' IDENTIFIED BY '$MYSQL_ROOT_PWD' WITH GRANT OPTION;"
    echo "MySQL - Grant acces for user 'root' into database '$MYSQL_DB_NAME' for the following IP mask '$MYSQL_GRANT_IPS' using password '$MYSQL_ROOT_PWD' "
    # echo "MySQL - Grant query: $MYSQL_GRANT_QUERY"
    mysql -u root -p$MYSQL_ROOT_PWD --host=$MYSQL_CONTAINER_IP --execute="$MYSQL_GRANT_QUERY"
    mysql -u root -p$MYSQL_ROOT_PWD --host=$MYSQL_CONTAINER_IP --execute="FLUSH PRIVILEGES;"
    
    echo "MySQL - Importing Quartz tables into '$MYSQL_DB_NAME'"
    mysql -u root -p$MYSQL_ROOT_PWD --host=$MYSQL_CONTAINER_IP  $MYSQL_DB_NAME < $QUARTZ_MYSQL_SCRIPT
    
    echo "MySQL - Installation & configuration finished successfully"
    
    echo ""
    echo ""
}

# *************************************************************************************************************
# BPMS
# *************************************************************************************************************
function run_bpms() {
    BPMS_NODE_INSTANCE=$1
    
    echo "*************************************************************************************************************"
    echo "BPMS instance #$BPMS_NODE_INSTANCE"
    echo "*************************************************************************************************************"
    
    # Create the BPMS container.
    BPMS_CONTAINER_ARGUMENTS="-e BPMS_CONNECTION_URL=\"$MYSQ_DB_URL\" "
    BPMS_CONTAINER_ARGUMENTS="$BPMS_CONTAINER_ARGUMENTS -e BPMS_CONNECTION_DRIVER=mysql "
    BPMS_CONTAINER_ARGUMENTS="$BPMS_CONTAINER_ARGUMENTS  -e BPMS_CONNECTION_USER=root "
    BPMS_CONTAINER_ARGUMENTS="$BPMS_CONTAINER_ARGUMENTS -e BPMS_CONNECTION_PASSWORD=$MYSQL_ROOT_PWD "
    BPMS_CONTAINER_ARGUMENTS="$BPMS_CONTAINER_ARGUMENTS -e BPMS_ZOOKEEPER_SERVER=$ZK_HOST:$ZK_PORT "
    BPMS_CONTAINER_ARGUMENTS="$BPMS_CONTAINER_ARGUMENTS -e BPMS_CLUSTER_NODE=$BPMS_NODE_INSTANCE "
    BPMS_CONTAINER_ARGUMENTS="$BPMS_CONTAINER_ARGUMENTS -e BPMS_CLUSTER_NAME=$CLUSTER_NAME "
    BPMS_CONTAINER_ARGUMENTS="$BPMS_CONTAINER_ARGUMENTS -e BPMS_VFS_LOCK=$VFS_LOCK "
    BPMS_CONTAINER_ARGUMENTS="$BPMS_CONTAINER_ARGUMENTS -e JBOSS_NODE_NAME=node$BPMS_NODE_INSTANCE "
    
    echo "BPMS - Starting container using the folowing arguments: $BPMS_CONTAINER_ARGUMENTS"
    #echo "BPMS - Run it using: 'docker run -t -i -P $BPMS_CONTAINER_ARGUMENTS --name bpms-node$BPMS_NODE_INSTANCE $BPMS_IMAGE_NAME:$BPMS_IMAGE_VERSION /bin/bash'"
    bpms_container_id=$(docker run -d -P $BPMS_CONTAINER_ARGUMENTS --name bpms-node$BPMS_NODE_INSTANCE $BPMS_IMAGE_NAME:$BPMS_IMAGE_VERSION)
    BPMS_CONTAINER_IP=$(docker inspect $bpms_container_id | grep IPAddress | awk '{print $2}' | tr -d '",')
    BPMS_CURRENT_NODE_IP="$BPMS_CONTAINER_IP"
    
    if [ "$BPMS_NODE_INSTANCE" != "1" ]; then
          HA_HOSTS="$HA_HOSTS,"
    fi
    HA_HOSTS="$HA_HOSTS$BPMS_CONTAINER_IP:8080"

    # TODO: Wait for BPMS webapp started - check $BPMS_CONTAINER_IP:8080/kie-wb (Including a timeout if startup fails)
    echo "BPMS - JBoss BPMS container started (server instance #$BPMS_NODE_INSTANCE) at $BPMS_CONTAINER_IP"
    echo "BPMS - You can navigate at URL 'http://$BPMS_CONTAINER_IP:8080/kie-wb'"
    
    echo ""
    echo ""
}


# *************************************************************************************************************
# Helper functions
# *************************************************************************************************************
function wait_for_bpms() {
    NODE_IP=$1
    KEYWORD=login
    #URL_TO_CHECK="http://$NODE_IP:8080/kie-wb/org.kie.workbench.KIEWebapp/KIEWebapp.html?"
    # Wait for dashbuilder application to be up, as it's the last one to deploy.
    URL_TO_CHECK="http://$NODE_IP:8080/dashbuilder/"
    
    IS_STARTED=$(curl --silent $URL_TO_CHECK | grep $KEYWORD)
    while [ "$IS_STARTED" == "" ]
    do
        # Not started yet.
        echo "JBoss BPMS server with IP address $NODE_IP is not started yet..."
        sleep 30
        IS_STARTED=$(curl --silent $URL_TO_CHECK | grep $KEYWORD)
    done
    echo "JBoss BPMS server with IP address $NODE_IP started!"
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
        -db-root-pwd )              shift
                                    MYSQL_ROOT_PWD=$1
                                    ;;
        -h | --help )               usage
                                    exit 1
                                    ;;
        * )                         usage
                                    exit 1
    esac
    shift
done

# *************************************************************************************************************
# Initialization & checks
# *************************************************************************************************************
init

# *************************************************************************************************************
# Zookeeper / Helix
# *************************************************************************************************************
run_zk_helix


# *************************************************************************************************************
# Database
# *************************************************************************************************************
run_mysql
sleep 5

# *************************************************************************************************************
# BPMS
# *************************************************************************************************************
for (( bpms_instance=1; bpms_instance<=$CLUSTER_INSTANCES; bpms_instance++ ))
do
   run_bpms $bpms_instance
   
   # BPMS server instances cannot be run at same time.. wait for each one to startup.
   wait_for_bpms "$BPMS_CURRENT_NODE_IP"
done

# *************************************************************************************************************
# HAProxy
# *************************************************************************************************************
run_haproxy

# Exit with no errors
exit 0