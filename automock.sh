#!/bin/bash
REPODIR="/home/`whoami`/repo"
if [[ $1 = "clean" ]]; then
  rm -rf $REPODIR/
  mkdir $REPODIR/
  for (( ver=18 ; ver<=19 ; ver++ ))
    do
      mkdir $REPODIR/fc$ver/ $REPODIR/fc$ver/x86_64/ $REPODIR/fc$ver/i386/ $REPODIR/fc$ver/source
    done
  exit
elif [[ $1 = *.spec && $2 = 1[89] ]]; then
  FILE=`readlink -f $1`
  #FEDVER=`echo $FILE | sed -e 's/^.*\(fc1[8-9]\).*$/\1/' -e 's/fc//'`
  FEDVER="$2"
  PACKAGENAME=`basename $FILE | sed -e 's/\.spec//'`
  PACKAGEDIR=`dirname $FILE`
  #Remove older SRPMs, RPMs and logs
  rm -rf $REPODIR/fc$FEDVER/source/$PACKAGENAME/ $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/ $REPODIR/fc$FEDVER/i386/$PACKAGENAME/
  #Create logs dirs
  mkdir -p $REPODIR/fc$FEDVER/source/$PACKAGENAME/logs/ $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/logs/ $REPODIR/fc$FEDVER/i386/$PACKAGENAME/logs/
  #Build SRPM
  mock --buildsrpm --resultdir=$REPODIR/"%(dist)s"/source/$PACKAGENAME/ --spec $FILE --source $PACKAGEDIR/SOURCES/
  #Move source logs to separate directory
  find $REPODIR/fc$FEDVER/source/$PACKAGENAME/ -type f -name '*.log' -exec mv -f {} $REPODIR/fc$FEDVER/source/$PACKAGENAME/logs/ \;
  #Delete temp mock files and SRPMs from source repo
  find $REPODIR/fc$FEDVER/source/$PACKAGENAME/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -delete
  #Update source repo
  createrepo --update $REPODIR/fc$FEDVER/source/
  #Build RPMs for x86_64
  mock -r fedora-$FEDVER-x86_64 --rebuild --resultdir=$REPODIR/"%(dist)s"/x86_64/$PACKAGENAME/ $REPODIR/fc$FEDVER/source/$PACKAGENAME/*.src.rpm
  #Move x86_64 logs to separate directory
  find $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/ -type f -name '*.log' -exec mv -f {} $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/logs/ \;
  #Delete temp mock files and SRPMs from x86_64 repo
  find $REPODIR/fc$FEDVER/x86_64/$PACKAGENAME/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -o -name '*.src.rpm' -delete
  #Update x86_64 repo
  createrepo --update $REPODIR/fc$FEDVER/x86_64/
  #Build RPMs for i386
  mock -r fedora-$FEDVER-i386 --rebuild --resultdir=$REPODIR/"%(dist)s"/i386/$PACKAGENAME/ $REPODIR/fc$FEDVER/source/$PACKAGENAME/*.src.rpm
  #Move i386 logs to separate directory
  find $REPODIR/fc$FEDVER/i386/$PACKAGENAME/ -type f -name '*.log' -exec mv -f {} $REPODIR/fc$FEDVER/i386/$PACKAGENAME/logs/ \;
  #Delete temp mock files and SRPMs from i386 repo
  find $REPODIR/fc$FEDVER/i386/$PACKAGENAME/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -o -name '*.src.rpm' -delete
  #Update i386 repo
  createrepo --update $REPODIR/fc$FEDVER/i386/
fi
