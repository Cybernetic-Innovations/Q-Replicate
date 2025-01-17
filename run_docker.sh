#!/bin/bash
# Expect three parameters:
#    1. Rest port
#    2. Docker image
#    3. Replicate password
if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
  echo "Usage: run_docker.sh <Rest port> <Docker image> <Replicate password>"
  exit 1
fi
#docker run --name qlikr -d -e ReplicateRestPort=$1 -e ReplicateAdminPassword=$3 -p $1:$1 --expose $1 --mount type=bind,source=/replicate/qre-docker/data,target=/replicate/qre-docker/data $2 --privileged
docker run --name qlikr --platform linux/amd64 -d -e ReplicateRestPort=$1 -e ReplicateAdminPassword=$3 -p $1:$1 --expose $1  $2 --privileged
