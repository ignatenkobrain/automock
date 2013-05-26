#!/bin/bash
REPODIR="/home/repos/build"
function updateselinux
{
  SELINUXSTATUS=`sestatus | grep "SELinux status" | awk '{print($3)}'`
  SELINUXHOMEDIRSSTATUS=`getsebool httpd_enable_homedirs | awk '{print($3)}'`
  if [[ $SELINUXSTATUS = enabled ]]; then
    if [[ $1 = /home* && $SELINUXHOMEDIRSSTATUS = off ]]; then
      sudo setsebool -P httpd_enable_homedirs 1
    fi
    sudo semanage fcontext -a -t public_content_t "$REPODIR(/.*)?"
    sudo restorecon -F -R -v $1
  fi
}
function build_clean
{
  # Build RPMs for x86_64
  mock -r brain-$FEDVER-$1 --arch=$2 --rebuild --resultdir=$REPO/fc$FEDVER/$1/$2/ $REPO/source/*.src.rpm
  # Delete temp mock files and SRPMs from $1 repo
  find $REPO/fc$FEDVER/$1/$2 -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -o -name '*.src.rpm' | xargs rm -f
  updateselinux
}
if [[ $1 = git://*.git && $2 =~ ^[a-f0-9]{40}$ && $3 = 1[89] ]]; then
  # Initializate REPO variable at date
  REPO="${REPODIR}/`date +"%d.%m.%Y-%H:%M:%S"`"
  # Cutting reponame
  PACKAGENAME=`echo $1 | sed -e 's/^.*\///' -e 's/\.git$//'`
  # Initializate git dirs
  export GIT_WORK_TREE="${REPO}"
  export GIT_DIR="${GIT_WORK_TREE}/.git"
  # Cloning git repo
  git clone $1 $REPO
  # Reset HEAD to sha in $2
  git reset --hard $2
  # Read full link to spec file
  FILE=$(readlink -f $REPO/*.spec)
  # Initializate version Fedora
  FEDVER="$3"
  # Create src dir (temporary)
  mkdir -p $REPO/SOURCES/
  # Move sources to separate dir
  find $REPO -maxdepth 1 -type f -regextype "posix-extended" -not -regex '.*\.spec|.*\/README.md' -exec mv -f {} $REPO/SOURCES/ \;
  # Build SRPM
  mock -r brain-$FEDVER-`arch` --buildsrpm --resultdir=$REPO/fc$FEDVER/source/ --spec $FILE --source $REPO/SOURCES/
  # Delete temp mock files and SRPMs from source repo
  find $REPO/fc$FEDVER/source/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -delete
  updateselinux
  build_clean "x86_64" "x86_64"
  build_clean "x86_64" "i386"
  build_clean "i386" "i386"
elif [[ $1 = clean ]]; then
  rm -rf $REPODIR/*
elif [[ $1 = update ]]; then
  createrepo --update $REPODIR
  updateselinux
fi
