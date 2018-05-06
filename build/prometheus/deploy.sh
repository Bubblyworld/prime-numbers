#!/bin/bash
# Deploys the prometheus docker image with prometheus.yaml as a bound volume
# for configuration. Expects the guypj/instrumenting docker bridge network
# to have been created.
#
# This script should be run from the root directory of the repo.
set -e
dir=`pwd`/build/prometheus

if [[ ! $(docker network ls | grep guypj/instrumenting) ]]; then
  echo "Error: expected docker bridge network guypj/instrumenting to be running."
  exit 1
fi

docker run \
  -p 9090:9090 \
  -v $dir:/config:ro \
  --network guypj/instrumenting \
  --name prometheus \
  prom/prometheus --config.file=/config/prometheus.yaml
