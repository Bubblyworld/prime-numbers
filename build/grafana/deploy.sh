#!/bin/bash
# Deploys the grafana docker image with datasources.yaml as a bound volume
# for provisioning configuration. Expects the guypj/instrumenting docker
# bridge network to have been created.
set -e
dir=`pwd`/build/grafana

if [[ ! $(docker network ls | grep guypj/instrumenting) ]]; then
  echo "Error: expected docker bridge network guypj/instrumenting to be running."
  exit 1
fi

# Remove running/exited prometheus containers.
docker ps -a | grep "grafana" \
             | cut -d " " -f 1 \
             | (xargs docker stop) \
             | (xargs docker rm)

docker run -d \
  -p 3000:3000 \
  -v $dir/datasources:/provisioning/datasources:ro \
  -v $dir/dashboards:/provisioning/dashboards:ro \
  -e "GF_PATHS_PROVISIONING=/provisioning" \
  --network guypj/instrumenting \
  --name grafana \
  grafana/grafana
