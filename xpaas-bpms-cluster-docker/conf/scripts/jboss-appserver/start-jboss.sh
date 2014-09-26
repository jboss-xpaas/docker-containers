#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script for BPMS webapplication
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

echo 'helix addNodeToCluster host1'
./helix-admin.sh --zkSvr $ZOOKEEPER_CON --addNode $CLUSTER_NAME $HOST_ID

./run-helix-controller.sh --zkSvr $ZOOKEEPER_CON --cluster $CLUSTER_NAME 2>&1 > /tmp/controller.log &


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


if [ $JBOSS_MODE == "DOMAIN" ]; then
    # Domain controller host instance
    echo "Starting JBoss Application Server in domain mode. This instance is the domain controller host."
    echo "Using HTTP address $JBOSS_BIND_ADDRESS:$JBOSS_HTTP_PORT / $JBOSS_BIND_ADDRESS:$JBOSS_HTTPS_PORT (SSL)"
    echo "Using management address $DOCKER_IP:$JJBOSS_MGMT_NATIVE_PORT"
    /opt/jboss-appserver/bin/domain.sh --host-config=host-master.xml -Djboss.messaging.cluster.password=$JBOSS_DOMAIN_CLUSTER_PASSWORD -Djboss.domain.master.address=$JBOSS_BIND_ADDRESS $JBOSS_COMMON_ARGS $JBOSS_ARGUMENTS

elif [ $JBOSS_MODE == "DOMAIN-HOST" ]; then
    # Domain host instance
    echo "Starting JBoss Application Server in domain mode. This instance is a domain host."
    echo "Using HTTP address $JBOSS_BIND_ADDRESS:$JBOSS_HTTP_PORT / $JBOSS_BIND_ADDRESS:$JBOSS_HTTPS_PORT (SSL)"
    echo "Using management address $DOCKER_IP:$JJBOSS_MGMT_NATIVE_PORT"
    echo "Using domain controller at $JBOSS_DOMAIN_MASTER_ADDR:$JBOSS_DOMAIN_MASTER_PORT"
    # jboss.management.native.port has to be changed when running several servers on a given host
    /opt/jboss-appserver/bin/domain.sh -host-config=host-slave.xml -Djboss.messaging.cluster.password=$JBOSS_DOMAIN_CLUSTER_PASSWORD -Djboss.domain.master.address=$JBOSS_DOMAIN_MASTER_ADDR -Djboss.domain.master.port=$JBOSS_DOMAIN_MASTER_PORT $JBOSS_COMMON_ARGS $JBOSS_ARGUMENTS
else
    # Standalone instance
    echo "Starting JBoss Application Server in standalone mode"
    echo "Using HTTP address $JBOSS_BIND_ADDRESS:$JBOSS_HTTP_PORT / $JBOSS_BIND_ADDRESS:$JBOSS_HTTPS_PORT (SSL)"
    echo "Using management address $DOCKER_IP:$JBOSS_MGMT_NATIVE_PORT"
    /opt/jboss-appserver/bin/standalone.sh --server-config=$JBOSS_STANDALONE_CONF_FILE -b $JBOSS_BIND_ADDRESS $JBOSS_COMMON_ARGS $JBOSS_ARGUMENTS
fi


exit 0
