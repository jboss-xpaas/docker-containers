#!/bin/sh

# Program arguments
#   1.- The program name

if [ $# -ne 1 ];
then
  echo "Missing arguments"
  echo "Usage: ./restart.sh <program_name>"
  exit 65
fi


# Restarts a supervisor program using supervisorctl 
supervisorctl restart $1

exit $?