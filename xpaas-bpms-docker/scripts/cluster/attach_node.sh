#!/bin/sh

# **********************************************************************************************************
# Script information
# ------------------
# This helper script is used to attach to the BPMS nodes that the "create_cluster.sh" script runs. 
# **********************************************************************************************************

# **********************************************************************************************************
# Program arguments
#
# -n | --node:                      The number of the BPMS node to connect via SSH
#                                   If not set defaults to "1"
# -h | --help:                      Script usage
# **********************************************************************************************************

NODE=1

# *************************************************************************************************************
# Usage function
# *************************************************************************************************************
function usage
{
    echo "usage: attach_node.sh [-n <node>]"
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

echo "Attaching to node '$NODE_NAME' with id '$NODE_ID'"
docker attach $NODE_ID

# Exit with no errors
exit 0