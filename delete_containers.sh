#!/bin/sh

docker ps -a

echo " "
echo "STOP xpaas-host1-Node"
docker stop xpaas-host1-Node

echo " "
echo "STOP xpaas-host2-Node"
docker stop xpaas-host2-Node

echo " "
echo "STOP xpaas-domain-Node"
docker stop xpaas-domain-Node

echo " "
echo "STOP xpaas-zookeeper "
docker stop xpaas-zookeeper

echo " "
echo " "
echo "REMOVE xpaas-host1-Node "
docker rm xpaas-host1-Node

echo " "
echo "REMOVE xpaas-host2-Node "
docker rm xpaas-host2-Node

echo " "
echo "REMOVE xpaas-domain-Node"
docker rm xpaas-domain-Node

echo " "
echo "REMOVE xpaas-zookeeper "
docker rm xpaas-zookeeper

docker ps -a