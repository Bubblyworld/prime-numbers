#!/bin/bash
# Script to cross-compile the test source for linux-x86_64, and attach the
# necessary bells and whistles for the docker image. Produces a .tar.gz
# bundle at ./bundle.tar.gzip.
#
# This script should be run in the root directory of the repo.
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

# Cleanup.
rm $dir/instrumenting