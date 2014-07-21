#!/bin/sh

###############################################################
# XPaas supervisor daemon control script
# This script is used to stop a supervisor program
###############################################################

# Program arguments
#   1.- The program name

if [ $# -ne 1 ];
then
  echo "Missing arguments"
  echo "Usage: ./stop.sh <program_name>"
  exit 65
fi


# Stops a supervisor program using supervisorctl 
supervisorctl stop $1

exit $?