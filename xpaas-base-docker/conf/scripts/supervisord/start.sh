#!/bin/sh

# Program arguments
#   1.- The program name

if [ $# -ne 1 ];
then
  echo "Missing arguments"
  echo "Usage: ./start.sh <program_name>"
  exit 65
fi


# Starts a supervisor program using supervisorctl 
supervisorctl start $1

exit $?