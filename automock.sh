#!/bin/bash
REPODIR="/home/repos"
function updaterepo
{
	createrepo $REPODIR/fc$FEDVER/$1/
}
function updateselinux
{
	# Call update nginx selinux
	`dirname $0`/nginx_selinux.sh "$REPODIR"
}
function build_clean
{
	# Build RPMs for x86_64
	mock -r brain-$FEDVER-$1 --rebuild --resultdir=$REPODIR/"%(dist)s"/$1/$PACKAGENAME/ $REPODIR/fc$FEDVER/source/$PACKAGENAME/*.src.rpm
	# Delete temp mock files and SRPMs from $1 repo
	find $REPODIR/fc$FEDVER/$1/$PACKAGENAME/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -o -name '*.src.rpm' | xargs rm -f
	# Update $1 repo
	updaterepo $1
	updateselinux
}
if [[ $1 = clean ]]; then
	rm -rf $REPODIR/*
elif [[ $1 = update ]]; then
	find $REPODIR -type d -regextype "posix-extended" -regex '.*\/(i386|source|x86_64)' -exec createrepo {} \;
	updateselinux
elif [[ $1 = *.spec && $2 = 1[89] ]]; then
	FILE=`readlink -f $1`
	FEDVER="$2"
	PACKAGENAME=`basename $FILE | sed -e 's/\.spec//'`
	PACKAGEDIR=`dirname $FILE`
	# Remove older SRPMs and RPMs
	rm -rf $REPODIR/fc$FEDVER/source/$PACKAGENAME/ $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/ $REPODIR/fc$FEDVER/i386/$PACKAGENAME/
	# Create dirs
	mkdir -p $REPODIR/fc$FEDVER/source/$PACKAGENAME/ $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/ $REPODIR/fc$FEDVER/i386/$PACKAGENAME/
	# Create src dir (temporary)
	mkdir -p $PACKAGEDIR/SOURCES/
	# Move sources to separate dir
	find $PACKAGEDIR -maxdepth 1 -type f -regextype "posix-extended" -not -regex '.*\.spec|.*\/README.md' -exec mv -f {} $PACKAGEDIR/SOURCES/ \;
	# Build SRPM
	mock -r brain-$FEDVER-`arch` --buildsrpm --resultdir=$REPODIR/"%(dist)s"/source/$PACKAGENAME/ --spec $FILE --source $PACKAGEDIR/SOURCES/
	# Move sources to previous dir
	mv -f $PACKAGEDIR/SOURCES/* $PACKAGEDIR/
	# Delete temporary src dir
	rm -rf $PACKAGEDIR/SOURCES/
	# Delete temp mock files and SRPMs from source repo
	find $REPODIR/fc$FEDVER/source/$PACKAGENAME/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -delete
	# Update source repo
	updaterepo "source"
	updateselinux
	build_clean "x86_64"
	build_clean "i386"
fi
