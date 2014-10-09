#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script for BPMS webapplication
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

# Starts JBoss Application Server using $JBOSS_ARGUMENTS, specified when running the container, if any.
JBOSS_COMMON_ARGS="-Djboss.bind.address=$JBOSS_BIND_ADDRESS -Djboss.bind.address.management=$DOCKER_IP -Djboss.management.native.port=$JBOSS_MGMT_NATIVE_PORT -Djboss.http.port=$JBOSS_HTTP_PORT -Djboss.https.port=$JBOSS_HTTPS_PORT -Djboss.ajp.port=$JBOSS_AJP_PORT -Djboss.management.http.port=$JBOSS_MGMT_HTTP_PORT -Djboss.management.https.port=$JBOSS_MGMT_HTTPS_PORT "

# MySQL docker container integartion.
# Default database name, if not set
if [[ -z "$BPMS_DATABASE" ]] ; then
    export BPMS_DATABASE="bpms"
fi

# If this JBoss BPMS container is linked with the official MySQL container, some environemnt variables will be present.
if [ -n "$MYSQL_PORT_3306_TCP_ADDR" ] &&  [ -n "$MYSQL_PORT_3306_TCP_PORT" ] &&  [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ] &&  [ -n "$BPMS_DATABASE" ]; then
    # MySQL environment variables are set. Proceed with automatic configuration.
    echo "Detected successfull MySQL container linked. Applying automatic configuration..."
    export BPMS_CONNECTION_URL="jdbc:mysql://$MYSQL_PORT_3306_TCP_ADDR:$MYSQL_PORT_3306_TCP_PORT/$BPMS_DATABASE"
    export BPMS_CONNECTION_DRIVER="mysql"
    export BPMS_CONNECTION_USER="root"
    export BPMS_CONNECTION_PASSWORD="$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
fi

export JBOSS_CLUSTER_ARGUMENTS=""
# BPMS cluster configuration
if [[ ! -z "$BPMS_CLUSTER_NAME" ]] ; then
    JBOSS_CLUSTER_ARGUMENTS=" -Djboss.bpms.git.host=$BPMS_GIT_HOST -Djboss.bpms.git.port=$BPMS_GIT_PORT -Djboss.bpms.git.dir=$BPMS_GIT_DIR -Djboss.bpms.ssh.host=$BPMS_SSH_HOST -Djboss.bpms.ssh.port=$BPMS_SSH_PORT "
    JBOSS_CLUSTER_ARGUMENTS=" $JBOSS_CLUSTER_ARGUMENTS -Djboss.bpms.index.dir=$BPMS_INDEX_DIR -Djboss.bpms.cluster.id=$BPMS_CLUSTER_NAME -Djboss.bpms.cluster.zk=$BPMS_ZOOKEEPER_SERVER -Djboss.bpms.cluster.node=$JBOSS_NODE_NAME"
    JBOSS_CLUSTER_ARGUMENTS=" $JBOSS_CLUSTER_ARGUMENTS -Djboss.bpms.vfs.lock=$BPMS_VFS_LOCK -Djboss.bpms.quartz.properties=$BPMS_QUARTZ_PROPERTIES -Djboss.messaging.cluster.password=$BPMS_CLUSTER_PASSWORD "
fi

# Cluster related.
if [[ ! -z "$BPMS_CLUSTER_NAME" ]] ; then
    echo "Configuring HELIX client for BPMS server instance '$JBOSS_NODE_NAME' into cluster '$BPMS_CLUSTER_NAME'"
    
    # Force to use full-ha profile.
    export JBOSS_STANDALONE_CONF_FILE="standalone-full-ha.xml"
    
    # Register the node.
    $HELIX_HOME/bin/helix-admin.sh --zkSvr $BPMS_ZOOKEEPER_SERVER --addNode $BPMS_CLUSTER_NAME $JBOSS_NODE_NAME
    
    # Rebalance the cluster resource.
    $HELIX_HOME/bin/helix-admin.sh --zkSvr $BPMS_ZOOKEEPER_SERVER --rebalance $BPMS_CLUSTER_NAME $BPMS_VFS_LOCK $BPMS_CLUSTER_NODES
fi

# Starts JBoss Application Server using $JBOSS_APPSERVER_ARGUMENTS, specified when running the container, if any.
echo "Starting JBoss Application Server in standalone mode"
echo "Using HTTP address $JBOSS_BIND_ADDRESS:$JBOSS_HTTP_PORT / $JBOSS_BIND_ADDRESS:$JBOSS_HTTPS_PORT (SSL)"
echo "Using management address $DOCKER_IP:$JBOSS_MGMT_NATIVE_PORT"
/opt/jboss-appserver/bin/standalone.sh --server-config=$JBOSS_STANDALONE_CONF_FILE -b $JBOSS_BIND_ADDRESS $JBOSS_COMMON_ARGS -Djboss.bpms.connection_url="$BPMS_CONNECTION_URL" -Djboss.bpms.driver="$BPMS_CONNECTION_DRIVER" -Djboss.bpms.username="$BPMS_CONNECTION_USER" -Djboss.bpms.password="$BPMS_CONNECTION_PASSWORD" $JBOSS_ARGUMENTS $JBOSS_CLUSTER_ARGUMENTS

exit 0