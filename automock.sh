#!/bin/bash
#################
#Requirements:  #
#               #
#x86_64 OS      #
#mock-scm       #
#rpmlint        #
#createrepo     #
#sed            #
#awk            #
#sudo           #
#################
# Exit status
EXIT=0
REPODIR="/home/repos/build"
# Get arch
MAINARCH=`arch`
if [[ ${MAINARCH} != x86_64 ]]; then
  echo "For build need x86_64"
  exit 1
fi
update ()
{
  # Create repodata
  repo "${REPODIR}"/fc{18,19}/
  updateselinux
}
updateselinux ()
{
  SELINUXSTATUS=`sestatus | grep "SELinux status" | awk '{print($3)}'`
  SELINUXHOMEDIRSSTATUS=`getsebool httpd_enable_homedirs | awk '{print($3)}'`
  if [[ ${SELINUXSTATUS} = enabled ]]; then
    if [[ "${REPODIR}" = /home/* && ${SELINUXHOMEDIRSSTATUS} = off ]]; then
      sudo setsebool -P httpd_enable_homedirs 1
    fi
    sudo semanage fcontext -a -t public_content_t "${REPODIR}(/.*)?"
    sudo restorecon -F -R -v "${REPODIR}"
  fi
}
repo ()
{
  for REPOSITORY in "$@"
  do
    createrepo --update ${REPOSITORY}
  done
}
build_clean ()
{
  # Build RPMs for x86_64
  mock -r ../../"${REPO}"/fedora-${FEDVER}-${1} --rebuild --resultdir="${REPO}"/${1}/ "${REPO}"/source/*.src.rpm --verbose >"${REPO}"/source/mock.log 2>&1
}
if [[ ${1} =~ ^git://.*\.git\?f1[89]$ ]]; then
  # Cutting reponame
  REPONAME="${1##git:*/}"
  REPONAME="${REPONAME%.*}"
  # Git url
  GIT="${1#git://}"
  GIT="${GIT%/*}"
  # Cutting branch ( also fedora version )
  BRANCH="${1##*.git?}"
  # Initializate Fedora version
  FEDVER="${BRANCH:1}"
  # Initializate REPO variable at date
  REPO="${REPODIR}/`date +"%d.%m.%Y-%H:%M:%S"`-${REPONAME}-fc${FEDVER}"
  # Touch directories
  mkdir -p "${REPO}"/ "${REPO}"/source/ "${REPO}"/build/
  # Copy original mock files
  cp /etc/mock/fedora-${FEDVER}-{i386,x86_64}.cfg "${REPO}"/
  # Postfix for dist
  POSTFIX="B"
  # Custom DIST
  DIST=`grep "config_opts\['dist'\]" "${REPO}"/fedora-${FEDVER}-${MAINARCH}.cfg | awk -F "'" '{print($4)}'`
  LINE=`grep -n "config_opts\['dist'\]" "${REPO}"/fedora-${FEDVER}-${MAINARCH}.cfg | cut -f 1 -d ":"`
  let LINE++
  # Edit mock configs
  for ARCH in {i386,x86_64}
  do
    sed -i -e "${LINE} s/^/config_opts['macros']['%dist']='.${DIST}.${POSTFIX}'\n/" "${REPO}"/fedora-${FEDVER}-${ARCH}.cfg
    echo "`echo "config_opts['scm'] = False"; \
           echo "config_opts['scm_opts']['method'] = 'git'"; \
           echo "#config_opts['scm_opts']['cvs_get'] = 'cvs -d /srv/cvs co SCM_BRN SCM_PKG'"; \
           echo "config_opts['scm_opts']['git_get'] = 'git clone SCM_BRN git://${GIT}/SCM_PKG.git SCM_PKG'"; \
           echo "#config_opts['scm_opts']['svn_get'] = 'svn co file:///srv/svn/SCM_PKG/SCM_BRN SCM_PKG'"; \
           echo "config_opts['scm_opts']['spec'] = 'SCM_PKG.spec'"; \
           echo "config_opts['scm_opts']['ext_src_dir'] = '/dev/null'"; \
           echo "config_opts['scm_opts']['write_tar'] = True"; \
           echo "config_opts['scm_opts']['git_timestamps'] = True"; \
           echo "config_opts['scm_opts']['package'] = '${REPONAME}'"; \
           echo "config_opts['scm_opts']['branch'] = '${BRANCH}'"; \
           echo "config_opts['basedir']='${REPO}/build/basedir/'"; \
           echo "config_opts['cache_topdir'] = '${REPO}/build/cache/'"; \
           cat "${REPO}"/fedora-${FEDVER}-${ARCH}.cfg`" > "${REPO}"/fedora-${FEDVER}-${ARCH}.cfg
  done
  mock -r ../../"${REPO}"/fedora-${FEDVER}-${MAINARCH} --buildsrpm --scm-enable --resultdir="${REPO}"/source/ --verbose >"${REPO}"/source/mock.log 2>&1
  if [[ $? -eq 0 ]]; then
    build_clean "x86_64"
    build_clean "i386"
  else
    echo "Failed!"
    echo "See mock.log"
    EXIT=1
  fi
  sudo rm -rf "${REPO}"/build/
  update
elif [[ ${1} = clean ]]; then
  # Clean
  sudo rm -rf "${REPODIR}"/*
  # Create repodirs
  mkdir -p "${REPODIR}"/fc{18,19}/
  update
elif [[ ${1} = update ]]; then
  update
fi
sudo chown -R nginx:nginx "${REPO}"/
if [[ $EXIT -ne 0 ]]; then
  exit $EXIT
else
  exit 0
fi
