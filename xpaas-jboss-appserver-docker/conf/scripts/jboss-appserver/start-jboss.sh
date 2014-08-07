#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script
# This script can be overriden in order to start the appserver with custom configurations
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

# Starts JBoss Application Server using $JBOSS_ARGUMENTS, specified when running the container, if any.
JBOSS_COMMON_ARGS="-Djboss.bind.address=$JBOSS_BIND_ADDRESS -Djboss.bind.address.management=$DOCKER_IP -Djboss.management.native.port=$JBOSS_MGMT_NATIVE_PORT -Djboss.http.port=$JBOSS_HTTP_PORT -Djboss.https.port=$JBOSS_HTTPS_PORT -Djboss.ajp.port=$JBOSS_AJP_PORT -Djboss.management.http.port=$JBOSS_MGMT_HTTP_PORT -Djboss.management.https.port=$JBOSS_MGMT_HTTPS_PORT "

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