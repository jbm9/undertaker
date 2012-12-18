#!/bin/bash
#
# Extract all subdirectories from a git repo, as their current names
#
# Usage: extract_subdir.sh <repo> <newremote>
#
# Assumes it can ssh ${newremote} init_repo.sh ${newrepo} and have the new bare repo created.
#
# Based very loosely on http://www.pither.com/articles/2009/02/04/extracting-a-subdirectory-from-git-as-a-new-git-repository

set -e

repo=$1
newremote=$2


if [ "x${repo}" = "x" ]; then
    echo "Need a repo specified."
    exit 2
fi

if [ "x${newremote}" = "x" ]; then
    echo "Need a newremote specified."
    exit 2
fi

dirs=$(find ${repo} -type d -maxdepth 1 -mindepth 1)

for d in $dirs; do
    if [ -f $d/PRIVATE -o -f $d/DONE -o -f $d/HEAD ]; then
	echo "   >>>>> $d is PRIVATE "
	continue
    fi

    echo $d

    dp=$(echo $d | sed -e "s,$repo/*,,")

    ./extract_subdir.sh ${repo} $dp $dp $newremote
    touch $d/DONE
done