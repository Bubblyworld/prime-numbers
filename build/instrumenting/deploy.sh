#!/bin/bash
# Calls build.sh to generate the docker image guypj/instrumenting:latest, and
# then deploys it as a docker container with the relevant configuration. Removes
# any running guypj/instrumenting containers beforehand, else ports will get
# clobbered.
#
# This script should be run in the root directory of the repo.
set -e
dir=`pwd`/build/instrumenting

# Remove running/exited guypj/instrumenting containers.
docker ps -a | grep "guypj/instrumenting" \
             | cut -d " " -f 1 \
             | (xargs docker stop) \
             | (xargs docker rm)

# Generate docker image.
$dir/build.sh

# Run docker container.
docker run -d -p8080 guypj/instrumenting:latest