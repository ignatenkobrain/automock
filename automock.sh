#!/bin/bash
source /opt/automock/automock.conf
# Hack for mock unpriveleged
PATH="/usr/bin:${PATH}"
build ()
{
  # Build RPMs
  mock -r ../../"${REPO}"/conf/fedora-${FEDVER}-${1} --rebuild --resultdir="${REPO}"/${1}/ "${REPO}"/source/*.src.rpm --verbose >"${REPO}"/${1}/mock.log 2>&1
}
# Exit status
STATUS=0
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
# Initializate start time
TIMESTAMP=`date +"%d.%m.%Y-%H:%M:%S"`
# Initializate REPO variable at date
REPO="${REPODIR}"/"${TIMESTAMP}"-${REPONAME}-fc${FEDVER}
# Touch directories
mkdir -m 770 "${REPO}"/ "${REPO}"/source/ "${REPO}"/x86_64/ "${REPO}"/i386/
# Touch invisible directory (for httpd) with build requirements
mkdir -m 700 "${REPO}"/build/ "${REPO}"/conf/
# Copy original mock files
cp /etc/mock/fedora-${FEDVER}-{i386,x86_64}.cfg "${REPO}"/conf/
# Postfix for dist
POSTFIX="B"
# Custom DIST
DIST=`grep "config_opts\['dist'\]" "${REPO}"/conf/fedora-${FEDVER}-${MAINARCH}.cfg | awk -F "'" '{print($4)}'`
LINE=`grep -n "config_opts\['dist'\]" "${REPO}"/conf/fedora-${FEDVER}-${MAINARCH}.cfg | cut -f 1 -d ":"`
let LINE++
# Edit mock configs
for ARCH in {i386,x86_64}
do
  sed -i -e "${LINE} s/^/config_opts['macros']['%dist']='.${DIST}.${POSTFIX}'\n/" "${REPO}"/conf/fedora-${FEDVER}-${ARCH}.cfg
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
         cat "${REPO}"/conf/fedora-${FEDVER}-${ARCH}.cfg`" > "${REPO}"/conf/fedora-${FEDVER}-${ARCH}.cfg
done
mock -r ../../"${REPO}"/conf/fedora-${FEDVER}-${MAINARCH} --buildsrpm --scm-enable --resultdir="${REPO}"/source/ --verbose >"${REPO}"/source/mock.log 2>&1
if [[ $? -eq 0 ]]; then
  build "x86_64"
  build "i386"
else
  echo "Failed!"
  echo "See mock.log"
  STATUS=1
fi
# Clean orphaned files
sudo rm -rf "${REPO}"/build/ "${REPO}"/conf/
# Delete complete task
rm -f "${TMPJOBSRUN}"/*.task
exit $STATUS
