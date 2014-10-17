#!/bin/sh
set -e
##########################################################################################################
# This script builds all XPaas Docker Images
# - XPaaS Base
# - XpaaS Zookeeper
# - XpaaS JBoss Application Server - JBoss EAP
# - XpaaS HAProxy
# - XpaaS BPMS for JBoss EAP
#
# NOTE: If necessary, run this script as superuser.
##########################################################################################################

pushd .
echo "Building all XPaaS docker images... eap"

# XPaaS Base
echo "Building XPaaS Base..."
cd xpaas-base-docker
./build.sh
cd ..

# XPaaS Zookeeper
echo "Building XPaaS Zookeeper..."
cd xpaas-zookeeper-docker
./build.sh
cd ..

# XPaaS JBoss EAP
echo "Building XPaaS JBoss EAP..."
cd xpaas-jboss-appserver-docker
./build.sh eap
cd ..

# XPaaS HAProxy
echo "Building XPaaS HAProxy..."
cd xpaas-haproxy-docker
./build.sh
cd ..

# XPaaS BPMS for JBoss EAP
echo "Building XPaaS BPMS for JBoss EAP..."
cd xpaas-bpms-docker/scripts
./build.sh bpms-eap
cd ../..


echo "Build completed."
popd

exit 0