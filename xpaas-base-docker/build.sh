#!/usr/bin/env bash

IMAGE_NAME="xpaas/xpaas_base"
IMAGE_TAG="1.0"

echo "Building the Docker container for $IMAGE_NAME:$IMAGE_TAG.."
docker build -t $IMAGE_NAME:$IMAGE_TAG .
# Generate current tag version and the "latest" one
#ID=$(docker build -t $IMAGE_NAME:$IMAGE_TAG .)
#docker tag $ID $IMAGE_NAME:latest # Add as latest tag too.
echo "Build done"