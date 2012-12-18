#!/bin/bash

# Creates a big dummy dir for testing the subdir extractor

mkdir dummyrepo
cd dummyrepo

git init
for x in a b c d e; do
    mkdir $x;
    cd $x
    for y in 1 2 3 4 5; do
	echo "$x$y" > $y
    done

    git add *
    git commit -m "Adds stuff in $x"

    cd ..
done

