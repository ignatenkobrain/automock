#!/bin/bash
REPODIR="/home/repos/build"
function updateselinux
{
  SELINUXSTATUS=`sestatus | grep "SELinux status" | awk '{print($3)}'`
  SELINUXHOMEDIRSSTATUS=`getsebool httpd_enable_homedirs | awk '{print($3)}'`
  if [[ $SELINUXSTATUS = enabled ]]; then
    if [[ $REPODIR = /home/* && $SELINUXHOMEDIRSSTATUS = off ]]; then
      sudo setsebool -P httpd_enable_homedirs 1
    fi
    sudo semanage fcontext -a -t public_content_t "$REPODIR(/.*)?"
    sudo restorecon -F -R -v $REPODIR
  fi
}
function build_clean
{
  # Build RPMs for x86_64
  mock -r fedora-$FEDVER-$1 --arch $2 --rebuild --resultdir=$REPO/fc$FEDVER/$1/$2/ $REPO/fc$FEDVER/source/*.src.rpm
  # Delete temp mock files and SRPMs from $1 repo
  find $REPO/fc$FEDVER/$1/$2 -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -o -name '*.src.rpm' | xargs rm -f
  updateselinux
}
if [[ $1 =~ ^git://.*\.git\?#[a-z0-9]{40}$ && $2 = 1[89] ]]; then
  # Cutting reponame
  REPONAME="${1##git:*/}"
  REPONAME="${REPONAME%.*}"
  # Cutting commit
  COMMIT="${1:(-40)}"
  # Initializate REPO variable at date
  REPO="${REPODIR}/`date +"%d.%m.%Y-%H:%M:%S"`-$REPONAME"
  # Cloning git repo
  git clone ${1%?#*} ${REPO}
  # Initializate git dirs
  export GIT_WORK_TREE="${REPO}"
  export GIT_DIR="${GIT_WORK_TREE}/.git"
  # Reset HEAD to sha in $2
  git reset --hard ${COMMIT}
  # Read full link to spec file
  FILE=$(readlink -f ${REPO}/*.spec)
  # Initializate version Fedora
  FEDVER="$3"
  # Create src dir (temporary)
  mkdir -p ${REPO}/SOURCES/
  # Move sources to separate dir
  find $REPO -maxdepth 1 -type f -regextype "posix-extended" -not -regex '.*\.spec|.*\/README.md' -exec mv -f {} $REPO/SOURCES/ \;
  # Build SRPM
  mock -r fedora-$FEDVER-`arch` --buildsrpm --resultdir=$REPO/fc$FEDVER/source/ --spec $FILE --source $REPO/SOURCES/
  # Move sources from separate dir
  mv $REPO/SOURCES/* $REPO/
  # Remove temp separate dir for sources
  rm -rf $REPO/SOURCES/
  # Delete temp mock files and SRPMs from source repo
  find $REPO/fc$FEDVER/source/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -delete
  updateselinux
  build_clean "x86_64" "x86_64"
  build_clean "x86_64" "i386"
  build_clean "i386" "i386"
elif [[ $1 = clean ]]; then
  rm -rf $REPODIR/*
elif [[ $1 = update ]]; then
  updateselinux
fi
