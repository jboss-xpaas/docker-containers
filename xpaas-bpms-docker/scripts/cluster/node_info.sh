#!/bin/sh

# **********************************************************************************************************
# Script information
# ------------------
# This helper script is used to show a BPMS instance container information 
# This script assumes that each node has as container name "bpms-nodeX" (where X is the number of the node)
# **********************************************************************************************************

# **********************************************************************************************************
# Program arguments
#
# -n | --node:                      The number of the BPMS node to show information
#                                   If not set defaults to "1"
# -h | --help:                      Script usage
# **********************************************************************************************************

NODE=1

# *************************************************************************************************************
# Usage function
# *************************************************************************************************************
function usage
{
    echo "usage: node_info.sh [-n <node>]"
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
if [[ -z "$NODE_ID" ]] ; then
    echo "Not found container id for node with name '$NODE_NAME'. Exiting!"
    exit 1
fi

NODE_IP=$(docker inspect $NODE_ID | grep IPAddress | awk '{print $2}' | tr -d '",')
if [[ -z "$NODE_IP" ]] ; then
    echo "Cannot get the IP address for container with name '$NODE_NAME' and id '$NODE_ID'. Exiting!"
    exit 1
fi

echo "*****************************************"
echo "Node number: $NODE"
echo "Container name: $NODE_NAME"
echo "Container id: $NODE_ID"
echo "Container IP: $NODE_IP"
echo "*****************************************"

# Exit with no errors
exit 0