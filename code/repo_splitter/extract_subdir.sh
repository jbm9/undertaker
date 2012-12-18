#!/bin/bash
#
# Extract a subdirectory from a git repo 
#
# Usage: extract_subdir.sh <repo> <subdir> <newrepo> <newremote>
#
# Extracts <subdir> from <repo>, naming the new git repo <newrepo>,
# pushing it to <newremote>, and then cloning it back down to
# <repo>/../<newrepo> (sorry if that's a bad assumption)
#
# NB: All .gitignore's in the subdir's parent paths are lost; you'll
# need to apply them to the newly created repo manually.  Sorry.
#
# Assumes it can ssh ${newremote} init_repo.sh ${newrepo} and have the new bare repo created.
#
# Based very loosely on http://www.pither.com/articles/2009/02/04/extracting-a-subdirectory-from-git-as-a-new-git-repository

repo=$1
subdir=$2
newrepo=$3
newremote=$4


set -e # be paranoid

if [ "x${repo}" = "x" ]; then
    echo "Need a repo specified."
    exit 2
fi

if [ "x${subdir}" = "x" ]; then
    echo "Need a subdir specified."
    exit 2
fi

if [ "x${newrepo}" = "x" ]; then
    echo "Need a newrepo specified."
    exit 2
fi

if [ "x${newremote}" = "x" ]; then
    echo "Need a newremote specified."
    exit 2
fi




tmpdir=$(mktemp -d /tmp/git_extract.XXXXXXXXX)

branchname="extract-$(echo $tmpdir |sed -e 's/^.*\.//g')"


echo "****** Creating new repo on remote node, named ${newrepo} on ${newremote}..."
ssh ${newremote} init_repo.sh ${newrepo}


echo "****** Creating new repo locally (${newrepo} in ${tmpdir})..."
cd ${tmpdir}
mkdir ${newrepo}
cd ${newrepo}
git init


echo "****** Creating directory filter (for ${subdir} out of ${repo}, branchname=${branchname}..."
cd ${repo}
echo git branch ${branchname}
git branch ${branchname}
echo git filter-branch --subdirectory-filter -f ${subdir} ${branchname} -- --all
git filter-branch --force --subdirectory-filter ${subdir} ${branchname} -- --all

echo git checkout ${branchname}
git checkout ${branchname}


cd ${tmpdir}/${newrepo}
echo "****** Creating new repo locally (${repo} from ${branchname})..."
git pull ${repo}


echo "****** Adding new remote (${newremote}:${newrepo}.git)..."
git remote add ${newrepo} ssh://${newremote}/~/gitrepos/${newrepo}.git

echo "****** Pushing new repo state to remote for ${newrepo}..."
git push ${newrepo} master

echo "****** Cloning new repo from remote to local, from ${newremote}:${newrepo}.git..."
cd ${repo}
cd ..
git clone ssh://${newremote}/~/gitrepos/${newrepo}.git

echo "****** Cleaning up local git state (in ${repo}, force removing branch ${branchname})"
cd ${repo}
git checkout master
git branch -D ${branchname}

echo "****** Deleting tmpdir..."
chmod -R u+w ${tmpdir}
rm -r ${tmpdir}
echo "****** Done."
