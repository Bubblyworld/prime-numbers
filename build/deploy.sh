#!/bin/bash
# Script to ensure that the guypj/instrumenting docker bridge network has been
# created, and deploy each of the three services this project needs to it:
#
#  * /build/instrumenting
#  * /build/prometheus
#  * /build/grafana
#
# This script should be run from the root directory of the repo.
set -e
dir=`pwd`/build

if [[ ! $(docker network ls | grep guypj/instrumenting) ]]; then
  docker network create guypj/instrumenting
fi

$dir/instrumenting/deploy.sh \
  && $dir/prometheus/deploy.sh