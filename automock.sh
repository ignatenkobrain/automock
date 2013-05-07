#!/bin/bash
HOMEDIR="/home/`whoami`"
function buildrpm
{
  #Build RPMs for x86_64
  mock -r fedora-$FEDVER-x86_64 --rebuild --resultdir=$HOMEDIR/repo/"%(dist)s"/"%(target_arch)s"/os/ $1
  #Build RPMs for i386
  mock -r fedora-$FEDVER-i386 --rebuild --resultdir=$HOMEDIR/repo/"%(dist)s"/"%(target_arch)s"/os/ $1
}
if [[ $1 = "clean" ]]; then
  rm -rf $HOMEDIR/repo/
  mkdir $HOMEDIR/repo/ $HOMEDIR/repo/lastlogs/ $HOMEDIR/repo/lastlogs/source/ $HOMEDIR/repo/lastlogs/x86_64/ $HOMEDIR/repo/lastlogs/i386/
  for (( ver=18 ; ver<=19 ; ver++ ))
    do
      mkdir $HOMEDIR/repo/fc$ver/ $HOMEDIR/repo/fc$ver/x86_64/ $HOMEDIR/repo/fc$ver/i386/ $HOMEDIR/repo/fc$ver/source
      mkdir $HOMEDIR/repo/fc$ver/x86_64/os/ $HOMEDIR/repo/fc$ver/i386/os/ $HOMEDIR/repo/fc$ver/x86_64/debug/ $HOMEDIR/repo/fc$ver/i386/debug/
      createrepo $HOMEDIR/repo/fc$ver/source/
      createrepo $HOMEDIR/repo/fc$ver/x86_64/os/
      createrepo $HOMEDIR/repo/fc$ver/i386/os/
      createrepo $HOMEDIR/repo/fc$ver/x86_64/debug/
      createrepo $HOMEDIR/repo/fc$ver/i386/debug/
    done
  exit
elif [[ $1 = *.spec && $2 = 1[89] ]]; then
  FILE=`readlink -f $1`
  #FEDVER=`echo $FILE | sed -e 's/^.*\(fc1[8-9]\).*$/\1/' -e 's/fc//'`
  FEDVER="$2"
  PACKAGENAME=`basename $FILE | sed -e 's/\.spec//'`
  PACKAGEDIR=`dirname $FILE`
  #Build SRPM
  mock --buildsrpm --resultdir=$HOMEDIR/repo/"%(dist)s"/source/ --spec $FILE --source $PACKAGEDIR/SOURCES/
  buildrpm $HOMEDIR/repo/fc$FEDVER/source/$PACKAGENAME*.src.rpm
  #Move last source logs to separate directory
  find $HOMEDIR/repo/fc$FEDVER/source/ -type f -name '*.log' -exec mv {} $HOMEDIR/repo/lastlogs/source/ \;
  #Move last x86_64 logs to separate directory
  find $HOMEDIR/repo/fc$FEDVER/x86_64/os/ -type f -name '*.log' -exec mv {} $HOMEDIR/repo/lastlogs/x86_64/ \;
  #Move last i386 logs to separate directory
  find $HOMEDIR/repo/fc$FEDVER/i386/os/ -type f -name '*.log' -exec mv {} $HOMEDIR/repo/lastlogs/i386/ \;
  #Delete SRPMs from x86_64 non-source repo
  find $HOMEDIR/repo/fc$FEDVER/x86_64/os/ -type f -name '*.src.rpm' -delete
  #Delete SRPMs from i386 non-source repo
  find $HOMEDIR/repo/fc$FEDVER/i386/os/ -type f -name '*.src.rpm' -delete
  #Delete temp mock files
  find $HOMEDIR/repo/fc$FEDVER/ -type f -not -name '*.rpm' -delete
  #Move debuginfo x86_64 to separate repository
  find $HOMEDIR/repo/fc$FEDVER/x86_64/os/ -type f -name '*debuginfo*' -exec mv {} $HOMEDIR/repo/fc$FEDVER/x86_64/debug/ \;
  #Move debuginfo i386 to separate repository
  find $HOMEDIR/repo/fc$FEDVER/i386/os/ -type f -name '*debuginfo*' -exec mv {} $HOMEDIR/repo/fc$FEDVER/x86_64/debug/ \;
  createrepo --update $HOMEDIR/repo/fc$FEDVER/source/
  createrepo --update $HOMEDIR/repo/fc$FEDVER/x86_64/os/
  createrepo --update $HOMEDIR/repo/fc$FEDVER/i386/os/
  createrepo --update $HOMEDIR/repo/fc$FEDVER/x86_64/debug/
  createrepo --update $HOMEDIR/repo/fc$FEDVER/i386/debug/
fi
