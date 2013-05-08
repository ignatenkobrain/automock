#!/bin/bash
REPODIR="/home/`whoami`/repo"
function buildrpm
{
  #Build RPMs for x86_64
  mock -r fedora-$FEDVER-x86_64 --rebuild --resultdir=$REPODIR/"%(dist)s"/x86_64/os/ $1
  #Build RPMs for i386
  mock -r fedora-$FEDVER-i386 --rebuild --resultdir=$REPODIR/"%(dist)s"/i386/os/ $1
}
if [[ $1 = "clean" ]]; then
  rm -rf $REPODIR/
  mkdir $REPODIR/ $REPODIR/lastlogs/ $REPODIR/lastlogs/source/ $REPODIR/lastlogs/x86_64/ $REPODIR/lastlogs/i386/
  for (( ver=18 ; ver<=19 ; ver++ ))
    do
      mkdir $REPODIR/fc$ver/ $REPODIR/fc$ver/x86_64/ $REPODIR/fc$ver/i386/ $REPODIR/fc$ver/source
      mkdir $REPODIR/fc$ver/x86_64/os/ $REPODIR/fc$ver/i386/os/ $REPODIR/fc$ver/x86_64/debug/ $REPODIR/fc$ver/i386/debug/
    done
  exit
elif [[ $1 = *.spec && $2 = 1[89] ]]; then
  FILE=`readlink -f $1`
  #FEDVER=`echo $FILE | sed -e 's/^.*\(fc1[8-9]\).*$/\1/' -e 's/fc//'`
  FEDVER="$2"
  PACKAGENAME=`basename $FILE | sed -e 's/\.spec//'`
  PACKAGEDIR=`dirname $FILE`
  #Remove older RPMs, SRPM of this package
  find $REPODIR/fc$FEDVER/ -type f -name '$PACKAGENAME*' -delete
  #Build SRPM
  mock --buildsrpm --resultdir=$REPODIR/"%(dist)s"/source/ --spec $FILE --source $PACKAGEDIR/SOURCES/
  #Call func to build RPMs
  buildrpm $REPODIR/fc$FEDVER/source/$PACKAGENAME*.src.rpm
  #Move last source logs to separate directory
  find $REPODIR/fc$FEDVER/source/ -type f -name '*.log' -exec mv {} $REPODIR/lastlogs/source/ \;
  #Move last x86_64 logs to separate directory
  find $REPODIR/fc$FEDVER/x86_64/os/ -type f -name '*.log' -exec mv {} $REPODIR/lastlogs/x86_64/ \;
  #Move last i386 logs to separate directory
  find $REPODIR/fc$FEDVER/i386/os/ -type f -name '*.log' -exec mv {} $REPODIR/lastlogs/i386/ \;
  #Delete SRPMs from x86_64 non-source repo
  find $REPODIR/fc$FEDVER/x86_64/os/ -type f -name '*.src.rpm' -delete
  #Delete SRPMs from i386 non-source repo
  find $REPODIR/fc$FEDVER/i386/os/ -type f -name '*.src.rpm' -delete
  #Delete temp mock files
  find $REPODIR/fc$FEDVER/ -type f -not -name '*.rpm' -delete
  #Move debuginfo x86_64 to separate repository
  find $REPODIR/fc$FEDVER/x86_64/os/ -type f -name '*debuginfo*' -exec mv {} $REPODIR/fc$FEDVER/x86_64/debug/ \;
  #Move debuginfo i386 to separate repository
  find $REPODIR/fc$FEDVER/i386/os/ -type f -name '*debuginfo*' -exec mv {} $REPODIR/fc$FEDVER/i386/debug/ \;
  createrepo --update $REPODIR/fc$FEDVER/source/
  createrepo --update $REPODIR/fc$FEDVER/x86_64/os/
  createrepo --update $REPODIR/fc$FEDVER/i386/os/
  createrepo --update $REPODIR/fc$FEDVER/x86_64/debug/
  createrepo --update $REPODIR/fc$FEDVER/i386/debug/
fi
