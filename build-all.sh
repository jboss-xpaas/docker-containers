#!/bin/sh

##########################################################################################################
# This script builds all XPaas Docker Images
# - XPaaS Base
# - XpaaS Fabric8
# - XpaaS Zookeeper
# - XpaaS JBoss Application Server - JBoss EAP
# - XpaaS JBoss Application Server - JBoss Wildfly
# - XpaaS HAProxy
# - XpaaS BPMS for JBoss EAP
# - XpaaS BPMS for JBoss Wildfly
# - XpaaS BRMS for JBoss EAP
# - XpaaS BRMS for JBoss Wildfly
#
# NOTE: If necessary, run this script as superuser.
##########################################################################################################

pushd .
echo "Building all XPaaS docker images..."

# XPaaS Base
echo "Buinding XPaaS Base..."
cd xpaas-base-docker
./build.sh
cd ..

# XPaaS Fabric8
echo "Buinding XPaaS Fabric8..."
cd xpaas-fabric8-docker
./build.sh
cd ..

# XPaaS Zookeeper
echo "Buinding XPaaS Zookeeper..."
cd xpaas-zookeeper-docker
./build.sh
cd ..

# XPaaS JBoss EAP
echo "Buinding XPaaS JBoss EAP..."
cd xpaas-jboss-appserver-docker
./build.sh
cd ..

# XPaaS JBoss Wildfly
echo "Buinding XPaaS JBoss Wildfly..."
cd xpaas-jboss-appserver-docker
./build.sh wildfly
cd ..

# XPaaS HAProxy
echo "Buinding XPaaS HAProxy..."
cd xpaas-haproxy-docker
./build.sh
cd ..

# XPaaS BPMS for JBoss EAP
echo "Buinding XPaaS BPMS for JBoss EAP..."
cd xpaas-bpms-docker/scripts
./build.sh bpms-eap
cd ../..

# XPaaS BPMS for JBoss Wildfly
echo "Buinding XPaaS BPMS for JBoss Wildfly..."
cd xpaas-bpms-docker/scripts
./build.sh bpms-wildfly
cd ../..

# XPaaS BRMS for JBoss EAP
echo "Buinding XPaaS BRMS for JBoss EAP..."
cd xpaas-brms-docker
./build.sh brms-eap
cd ..

# XPaaS BRMS for JBoss Wildfly
echo "Buinding XPaaS BRMS for JBoss Wildfly..."
cd xpaas-brms-docker
./build.sh brms-wildfly
cd ..

echo "Build completed."
popd

exit 0