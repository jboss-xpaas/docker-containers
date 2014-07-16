#!/bin/bash

if [[ -z "$ROOT_PASSWORD" ]] ; then
    echo "Not custom root password set. Using default password for root user."
    export ROOT_PASSWORD="xpaas"
fi

# Configure the root password
echo "Using '$ROOT_PASSWORD' as root password"
echo "root:$ROOT_PASSWORD" | chpasswd

exit $?