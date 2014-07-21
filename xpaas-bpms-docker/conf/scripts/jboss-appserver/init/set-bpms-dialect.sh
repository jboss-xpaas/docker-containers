#!/bin/bash

######################################################################################
# BPMS database configuration script
# This script configures BPMS webapp database connection parameters.
######################################################################################

if [[ -z "$BPMS_CONNECTION_DRIVER" ]] ; then
    echo "ERROR: No BPMS connection driver specified."
    exit 1
fi

if [[ -z "$BPMS_CONNECTION_URL" ]] ; then
    echo "ERROR: No BPMS connection URL specified."
    exit 1
fi

if [[ -z "$BPMS_CONNECTION_USER" ]] ; then
    echo "ERROR: No BPMS connection user specified."
    exit 1
fi

if [[ -z "$BPMS_CONNECTION_PASSWORD" ]] ; then
    echo "ERROR: No BPMS connection password specified."
    exit 1
fi

DEFAULT_DIALECT="org.hibernate.dialect.H2Dialect"
BPMS_WAR=/opt/jboss-appserver/standalone/deployments/kie-wb-wildfly.war

if [ "$BPMS_CONNECTION_DRIVER" == "mysql" ]; then
    DIALECT="org.hibernate.dialect.MySQLDialect"
	echo "Configuring BPMS web application for MySQL database..."
	/jboss/scripts/bpms/change-hibernate-dialect.sh -war $BPMS_WAR -d "$DIALECT"
fi

exit 0