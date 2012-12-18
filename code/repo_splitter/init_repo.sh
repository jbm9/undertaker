#!/bin/bash
#
# Initializes a new bare git repo for usage.
#
# Usage: init_repo.sh <reponame>
#

reponame=$1

if [ "x${reponame}" = "x" ]; then
    echo "Need a reponame"
    exit 2
fi

mkdir -p gitrepos
pushd gitrepos

mkdir ${reponame}.git
cd ${reponame}.git
git init --bare

popd