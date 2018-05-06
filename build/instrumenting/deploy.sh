#!/bin/bash
# Calls build.sh to generate the docker image guypj/instrumenting:latest, and
# then deploys it as a docker container with the relevant configuration. Removes
# any running guypj/instrumenting containers beforehand, else ports will get
# clobbered. Expects the guypj/instrumenting docker bridge network to be
# running.
#
# This script should be run in the root directory of the repo.
set -e
dir=`pwd`/build/instrumenting

if [[ ! $(docker network ls | grep guypj/instrumenting) ]]; then
  echo "Error: expected docker bridge network guypj/instrumenting to be running."
  exit 1
fi

# Remove running/exited guypj/instrumenting containers.
docker ps -a | grep "guypj/instrumenting" \
             | cut -d " " -f 1 \
             | (xargs docker stop) \
             | (xargs docker rm)

# Generate docker image.
$dir/build.sh

# Run docker container.
docker run \
  -p 8080:8080 \
  --network guypj/instrumenting \
  --name instrumenting \
  guypj/instrumenting:latest