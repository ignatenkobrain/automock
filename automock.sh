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
function repo
{
  createrepo --update $@
}
function build_clean
{
  # Build RPMs for x86_64
  setarch ${2} mock --no-cleanup-after -r ${REPO}/fedora-${FEDVER}-${1}--rebuild --resultdir=${REPO}/build/${1}/ ${REPO}/build/source/*.src.rpm
  # Delete temp mock files and SRPMs from ${1} repo
  find ${REPO}/build/${1}/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -o -name '*.src.rpm' | xargs rm -f
  updateselinux
}
if [[ ${1} =~ ^git://.*\.git\?#[a-z0-9]{40}$ && ${2} = 1[89] ]]; then
  # Get arch
  ARCH="`arch`"
  # Cutting reponame
  REPONAME="${1##git:*/}"
  REPONAME="${REPONAME%.*}"
  # Cutting commit
  COMMIT="${1:(-40)}"
  # Initializate version Fedora
  FEDVER="${2}"
  # Initializate REPO variable at date
  REPO="${REPODIR}/`date +"%d.%m.%Y-%H:%M:%S"`-${REPONAME}-fc${FEDVER}"
  # Cloning git repo
  git clone ${1%?#*} ${REPO}
  # Initializate git dirs
  export GIT_WORK_TREE="${REPO}"
  export GIT_DIR="${GIT_WORK_TREE}/.git"
  # Reset HEAD to sha in ${2}
  git reset --hard ${COMMIT}
  # Read full link to spec file
  FILE=$(readlink -f ${REPO}/*.spec)
  # Create src dir (temporary)
  mkdir -p ${REPO}/SOURCES/
  # Move sources to separate dir
  find ${REPO} -maxdepth 1 -type f -regextype "posix-extended" -not -regex '.*\.spec|.*\/README.md' -exec mv -f {} ${REPO}/SOURCES/ \;
  # Copy original mock files
  cp /etc/mock/fedora-${FEDVER}-{i386,x86_64}.cfg ${REPO}/
  # Formatting REPO for sed regex
  REGEXREPO=`echo "${REPO}" | sed 's/\//\//'`
  # Postfix for dist
  POSTFIX="B"
  # Custom DIST
  DIST="`grep "config_opts\['dist'\]" fedora-${FEDVER}-${ARCH}.cfg | awk -F "'" '{print($4)}'`"
  # Edit mock configs
  sed -i -e "2 s/^/config_opts['base_dir'] = '${REGEXREPO}'\n/" \
         -e "6 s/^/config_opts['macros']['%dist']='.${DIST}.${POSTFIX}'\n/" fedora-${FEDVER}-{i386,x86_64}.cfg
  # Build SRPM
  mock --no-cleanup-after -r ${REPO}/fedora-${FEDVER}-${ARCH} --buildsrpm --resultdir=${REPO}/build/source/ --spec ${FILE} --source ${REPO}/SOURCES/
  # Move sources from separate dir
  mv ${REPO}/SOURCES/* ${REPO}/
  # Remove temp separate dir for sources
  rm -rf ${REPO}/SOURCES/
  # Delete temp mock files and SRPMs from source repo
  find ${REPO}/build/source/ -type f -regextype "posix-extended" -not -regex '.*\.(rpm|log)' -delete
  updateselinux
  build_clean "x86_64" "x86_64"
  build_clean "x86_64" "i386"
  build_clean "i386" "i386"
  # Unset all variables
  unset ARCH REPONAME COMMIT FEDVER REPO GIT_WORK_TREE GIT_DIR FILE REGEXREPO POSTFIX DIST
elif [[ ${1} = clean ]]; then
  # Clean
  rm -rf ${REPODIR}/*
  # Create repodirs
  mkdir -p ${REPODIR}/fc{18,19}/
  # Create repodata
  repo ${REPODIR}/fc{18,19}/
elif [[ ${1} = update ]]; then
  updateselinux
fi
# Unset repodir
unset REPODIR
