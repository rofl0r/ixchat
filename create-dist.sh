#!/bin/sh
if [[ -z "$VER" ]] ; then
	echo set VER!
	exit
fi
me=`pwd`

proj=ixchat
projver=${proj}-${VER}
repo=http://github.com/rofl0r/$proj
repo=$PWD

tempdir=/tmp/${proj}-0000
rm -rf $tempdir
mkdir -p $tempdir

cd $tempdir
git clone $repo $projver
rm -rf $projver/.git
rm -rf $projver/docs

tar cJf $proj.tar.xz $projver/
mv $proj.tar.xz $me/$projver.tar.xz
