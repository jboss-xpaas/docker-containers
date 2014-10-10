#!/bin/sh

# Welcome message
echo Welcome to zookeeper
echo
echo Starting Zookeeper container: $ZOOKEEPER_NAME
echo ZOOKEEPER_DATA_DIR: $ZOOKEEPER_DATA_DIR
echo ENV ZOOKEEPER_CLIENT_PORT: $ENV ZOOKEEPER_CLIENT_PORT
echo ZOOKEEPER_REGISTERED_SERVERS: $ZOOKEEPER_REGISTERED_SERVERS
echo CLUSTER_NAME: $CLUSTER_NAME


# Generating zookeeper zoo.cfg
echo "# The number of milliseconds of each tick" >> /opt/zookeeper/conf/zoo.cfg
echo "tickTime=2000" >> /opt/zookeeper/conf/zoo.cfg
echo "# The number of ticks that the initial" >> /opt/zookeeper/conf/zoo.cfg
echo "# synchronization phase can take" >> /opt/zookeeper/conf/zoo.cfg
echo "initLimit=10" >> /opt/zookeeper/conf/zoo.cfg
echo "# The number of ticks that can pass between" >> /opt/zookeeper/conf/zoo.cfg
echo "# sending a request and getting an acknowledgement" >> /opt/zookeeper/conf/zoo.cfg
echo "syncLimit=5" >> /opt/zookeeper/conf/zoo.cfg
echo "# the directory where the snapshot is stored." >> /opt/zookeeper/conf/zoo.cfg
echo "# do not use /tmp for storage, /tmp here is just" >> /opt/zookeeper/conf/zoo.cfg
echo "# example sakes." >> /opt/zookeeper/conf/zoo.cfg
echo "dataDir=$ZOOKEEPER_DATA_DIR" >> /opt/zookeeper/conf/zoo.cfg
echo "# the port at which the clients will connect" >> /opt/zookeeper/conf/zoo.cfg
echo "clientPort=$ZOOKEEPER_CLIENT_PORT">> /opt/zookeeper/conf/zoo.cfg
echo "# the maximum number of client connections." >> /opt/zookeeper/conf/zoo.cfg
echo "# increase this if you need to handle more clients" >> /opt/zookeeper/conf/zoo.cfg
echo "#maxClientCnxns=60" >> /opt/zookeeper/conf/zoo.cfg
echo "#" >> /opt/zookeeper/conf/zoo.cfg
echo "# Be sure to read the maintenance section of the" >> /opt/zookeeper/conf/zoo.cfg
echo "# administrator guide before turning on autopurge." >> /opt/zookeeper/conf/zoo.cfg
echo "#" >> /opt/zookeeper/conf/zoo.cfg
echo "# http://zookeeper.apache.org/doc/current/zookeeperAdmin.html#sc_maintenance" >> /opt/zookeeper/conf/zoo.cfg
echo "#" >> /opt/zookeeper/conf/zoo.cfg
echo "# The number of snapshots to retain in dataDir" >> /opt/zookeeper/conf/zoo.cfg
echo "#autopurge.snapRetainCount=3" >> /opt/zookeeper/conf/zoo.cfg
echo "# Purge task interval in hours" >> /opt/zookeeper/conf/zoo.cfg
echo "# Set to "0" to disable auto purge feature" >> /opt/zookeeper/conf/zoo.cfg
echo "#autopurge.purgeInterval=1" >> /opt/zookeeper/conf/zoo.cfg
echo -e "$ZOOKEEPER_REGISTERED_SERVERS"
echo -e "$ZOOKEEPER_REGISTERED_SERVERS">> /opt/zookeeper/conf/zoo.cfg

# Run Zookeeper in server mode.
/opt/zookeeper/bin/zkServer.sh start


echo 'helix addCluster'
/opt/helix/bin/helix-admin.sh --zkSvr localhost:2181 --addCluster $CLUSTER_NAME


echo 'helix Adding vfs-repo as resource'
/opt/helix/bin/helix-admin.sh --zkSvr localhost:2181 --addResource $CLUSTER_NAME $VFS_REPO 1 LeaderStandby AUTO_REBALANCE


exit 0