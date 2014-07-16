#!/bin/sh

# Displays the current container IP address
echo $(ifconfig eth0 | egrep '([0-9]{1,3}\.){3}[0-9]{1,3}' | awk '{print $2}')
exit $?