#!/bin/sh

##########################################################################
# XPaas base initialization script
# 1.- Welcome message
##########################################################################

# Welcome message
echo "Welcome to XPaaS Base docker container"

# Exporting environment vairables for login shells (ssh)
env >> /etc/environment

exit 0