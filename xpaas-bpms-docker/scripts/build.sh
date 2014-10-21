#!/bin/bash

# Script arguments
# 1.- The docker image to build
#     Values are (case sensitive):
#       - bpms-wildfly
#       - bpms-eap

# Check image argument to build.
if [ $# -ne 1 ]; then
  echo "Missing argument: docker image to build."
  echo "Usage: ./build.sh [bpms-wildfly,bpms-eap]"
  exit 65
fi

# Check if argument value is wildfly or eap (case sensitive)
if [ ! "$1" == "bpms-eap" ] && [ ! "$1" == "bpms-wildfly" ]; then
    echo "Argument value must be [bpms-wildfly, bpms-eap]"
    exit 65
fi

# Script variables
IMAGE=$1
IMAGE_NAME="redhat/xpaas_bpmsuite"
IMAGE_TAG="1.0"

# Work on parent directory.
pushd .
cd ..

# Generate the dockerfile for the given image to build.
echo "Generating the dockerfile for $IMAGE"
if [ -f Dockerfile ]; then
    rm -f Dockerfile
fi

if [ "$1" == "bpms-wildfly" ]; then
IMAGE_NAME="redhat/xpaas_bpms_wildfly"
fi

cp -f "Dockerfile.$IMAGE" Dockerfile


# Build the container image.
echo "Building the Docker container for $IMAGE_NAME:$IMAGE_TAG.."
docker build --rm -t $IMAGE_NAME:$IMAGE_TAG .
echo "Build done"
rm -f Dockerfile

# Create the latest tag
docker tag $IMAGE_NAME:$IMAGE_TAG $IMAGE_NAME:latest

popd