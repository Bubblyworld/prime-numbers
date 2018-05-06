#!/bin/bash
# Script to cross-compile the test source for linux-x86_64, and attach the
# necessary bells and whistles for the docker image. Creates a docker image
# tagged guypj/instrumenting:latest. At the moment only the linux executable
# goes in the bundle, but for future projects we could add in credentials,
# config files etcetera.
#
# This script should be run in the root directory of the repo.
set -e
dir=`pwd`/build/instrumenting
file=bundle.tar.gz
out=$dir/$file

# (Cross-)Compile the latest repo version.
export GOPATH=`pwd`
export GOOS="linux"
export GOARCH="amd64"
go install guypj/instrumenting

# The output dir for the executable is different if it was cross-compiled.
if [[ ! -f ./bin/linux_amd64/instrumenting ]]; then
  cp ./bin/instrumenting $dir
else
  cp ./bin/linux_amd64/instrumenting $dir
fi

# Zip the bundle up - first remove the previous one.
if [[ -f $out ]]; then rm $out; fi
(cd $dir && tar -czf $file *)

# Generate the docker image.
(cd $dir && docker build -t guypj/instrumenting:latest .)

# Cleanup.
rm $dir/instrumenting
rm $out
docker images | grep "<none>" | awk '{ print $3 }' | xargs docker image rm