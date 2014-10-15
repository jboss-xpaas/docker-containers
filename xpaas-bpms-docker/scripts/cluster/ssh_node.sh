#!/bin/sh

# **********************************************************************************************************
# Script information
# ------------------
# This helper script is used to connect via SSH to the BPMS nodes that the "create_cluster.sh" script runs. 
# This script assumes that each node has as container name "bpms-nodeX" (where X is the number of the node)
# **********************************************************************************************************

# **********************************************************************************************************
# Program arguments
#
# -n | --node:                      The number of the BPMS node to connect via SSH
#                                   If not set defaults to "1"
# -h | --help:                      Script usage
# **********************************************************************************************************

NODE=1
SSH_USER=root

# *************************************************************************************************************
# Usage function
# *************************************************************************************************************
function usage
{
    echo "usage: create_cluster.sh [ [-name <cluster_name] [-vfs <vfs_lock_name] [-n <num_instances] [-zk <zk_server] [-db-url <db_url] [-db-driver <db_driver] [-db-user <db_user] [-db-pwd <db_pwd] ]"
}


while [ "$1" != "" ]; do
    case $1 in
        -n | --node )               shift
                                    NODE=$1
                                    ;;
        -h | --help )               usage
                                    exit 1
                                    ;;
        * )                         usage
                                    exit 1
    esac
    shift
done

NODE_NAME="bpms-node$NODE"
NODE_ID=$(docker ps -a | grep $NODE_NAME | cut -f1 -d " ")
NODE_IP=$(docker inspect $NODE_ID | grep IPAddress | awk '{print $2}' | tr -d '",')

if [[ -z "$NODE_ID" ]] ; then
    echo "Not found container id for node with name '$NODE_NAME'. Exiting!"
    exit 1
fi

if [[ -z "$NODE_IP" ]] ; then
    echo "Cannot get the IP address for container with name '$NODE_NAME' and id '$NODE_ID'. Exiting!"
    exit 1
fi

echo "Connecting to node '$NODE_NAME' with id '$NODE_ID' and IP address '$NODE_IP' via SSH"
ssh $SSH_USER@$NODE_IP -o StrictHostKeyChecking=no

# Exit with no errors
exit 0