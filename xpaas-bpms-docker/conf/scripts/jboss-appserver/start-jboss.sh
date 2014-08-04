#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script for BPMS webapplication
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

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


# Starts JBoss Application Server using $JBOSS_APPSERVER_ARGUMENTS, specified when running the container, if any.
echo "Starting JBoss Application Server in address $JBOSS_BIND_ADDRESS:$JBOSS_HTTP_PORT / $JBOSS_BIND_ADDRESS:$JBOSS_HTTPS_PORT (SSL) and management in address $DOCKER_IP:$JBOSS_MGMT_HTTP_PORT / $DOCKER_IP:$JBOSS_MGMT_HTTPS_PORT"
/opt/jboss-appserver/bin/standalone.sh --server-config=$JBOSS_STANDALONE_CONF_FILE -b $JBOSS_BIND_ADDRESS -Djboss.http.port=$JBOSS_HTTP_PORT -Djboss.https.port=$JBOSS_HTTPS_PORT -Djboss.ajp.port=$JBOSS_AJP_PORT -Djboss.management.http.port=$JBOSS_MGMT_HTTP_PORT -Djboss.management.https.port=$JBOSS_MGMT_HTTPS_PORT -Djboss.bind.address.management=$DOCKER_IP -Djboss.brms.connection_url="$BRMS_CONNECTION_URL" -Djboss.brms.driver="$BRMS_CONNECTION_DRIVER" -Djboss.brms.username="$BRMS_CONNECTION_USER" -Djboss.brms.password="$BRMS_CONNECTION_PASSWORD"  $JBOSS_APPSERVER_ARGUMENTS

exit 0