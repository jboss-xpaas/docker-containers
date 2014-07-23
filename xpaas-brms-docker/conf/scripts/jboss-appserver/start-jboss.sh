#!/bin/bash

###########################################################################################3
# Default JBoss Application Server startup script for BRMS webapplication
###########################################################################################3

#First argument is the current container IP address
DOCKER_IP=$1

# MySQL docker container integartion.
# Default database name, if not set
if [[ -z "$BRMS_DATABASE" ]] ; then
    export BRMS_DATABASE="brms"
fi

# If this JBoss BRMS container is linked with the official MySQL container, some environemnt variables will be present.
if [ -n "$MYSQL_PORT_3306_TCP_ADDR" ] &&  [ -n "$MYSQL_PORT_3306_TCP_PORT" ] &&  [ -n "$MYSQL_ENV_MYSQL_ROOT_PASSWORD" ] &&  [ -n "$BRMS_DATABASE" ]; then
    # MySQL environment variables are set. Proceed with automatic configuration.
    echo "Detected successfull MySQL container linked. Applying automatic configuration..."
    export BRMS_CONNECTION_URL="jdbc:mysql://$MYSQL_PORT_3306_TCP_ADDR:$MYSQL_PORT_3306_TCP_PORT/$BRMS_DATABASE"
    export BRMS_CONNECTION_DRIVER="mysql"
    export BRMS_CONNECTION_USER="root"
    export BRMS_CONNECTION_PASSWORD="$MYSQL_ENV_MYSQL_ROOT_PASSWORD"
fi

# Starts JBoss Application Server using $JBOSS_APPSERVER_ARGUMENTS, specified when running the container, if any.
echo "Starting JBoss Application Server in HTTP address 0.0.0.0:8080 and management address $DOCKER_IP"
/opt/jboss-appserver/bin/standalone.sh --server-config=standalone-full.xml -b 0.0.0.0 -Djboss.bind.address.management=$DOCKER_IP -Djboss.brms.connection_url="$BRMS_CONNECTION_URL" -Djboss.brms.driver="$BRMS_CONNECTION_DRIVER" -Djboss.brms.username="$BRMS_CONNECTION_USER" -Djboss.brms.password="$BRMS_CONNECTION_PASSWORD" $JBOSS_APPSERVER_ARGUMENTS

exit 0