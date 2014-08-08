#!/bin/sh

###############################################################
# XPaas current container IP
# This script obtains the current IP address for the container.
###############################################################

# Displays the current container IP address
echo $(ifconfig eth0 | egrep '([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $2}')