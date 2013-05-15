#!/bin/bash
REPODIR="/home/repos"
function updaterepo
{
	createrepo $REPODIR/fc$FEDVER/$1/
}
function updateselinux
{
	# Call update nginx selinux
	dirname $0`/nginx_selinux.sh "$REPODIR"
}
function build_clean
{
	#Build RPMs for x86_64
	mock -r fedora-$FEDVER-$1 --rebuild --resultdir=$REPODIR/"%(dist)s"/$1/$PACKAGENAME/ $REPODIR/fc$FEDVER/source/$PACKAGENAME/*.src.rpm
	#Delete temp mock files and SRPMs from $1 repo
	find $REPODIR/fc$FEDVER/$1/$PACKAGENAME/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -o -name '*.src.rpm' | xargs rm -f
	#Update $1 repo
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
	#Remove older SRPMs and RPMs
	rm -rf $REPODIR/fc$FEDVER/source/$PACKAGENAME/ $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/ $REPODIR/fc$FEDVER/i386/$PACKAGENAME/
	#Create dirs
	mkdir -p $REPODIR/fc$FEDVER/source/$PACKAGENAME/ $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/ $REPODIR/fc$FEDVER/i386/$PACKAGENAME/
	#Build SRPM
	mock -r fedora-$FEDVER-`arch` --buildsrpm --resultdir=$REPODIR/"%(dist)s"/source/$PACKAGENAME/ --spec $FILE --source $PACKAGEDIR/SOURCES/
	#Delete temp mock files and SRPMs from source repo
	find $REPODIR/fc$FEDVER/source/$PACKAGENAME/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -delete
	#Update source repo
	updaterepo "source"
	updateselinux
	case $3 in
		x86_64)
			build_clean "x86_64"
		;;
		i386)
			build_clean "i386"
		;;
		all)
			build_clean "x86_64"
			build_clean "i386"
		;;
		*)
			echo "Use arch"
			exit
		;;
	esac
fi
