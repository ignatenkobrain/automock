#!/bin/bash
#<LocationMatch "^/+$">
#    Options -Indexes
#    ErrorDocument 403 /.noindex.html
#</LocationMatch>
source automock.conf
backup ()
{
  cp "${1}" "${DIR}"/backups/
}
sudoers ()
{
  backup "/etc/sudoers"
  echo "Defaults:${USER} !requiretty
Defaults:apache !requiretty
${USER} ALL=(ALL) NOPASSWD: /usr/sbin/semanage, /usr/sbin/restorecon, /usr/sbin/setsebool, /usr/bin/rm
apache ALL=(${USER}) NOPASSWD: ${DIR}/automock.sh" >> /etc/sudoers
}
httpd ()
{
  backup "/etc/httpd/conf.d/welcome.conf"
  echo "DocumentRoot ${ROOT} 
Alias /repos ${REPODIR}/packages
Alias /automock ${DIR}/web
<Directory "${ROOT}">
  Options Indexes
  AllowOverride None
  Require all granted
  Order allow,deny
  Allow from all
</Directory>
<Directory "${DIR}">
  Options -Indexes
  AllowOverride None
  Require all granted
  Order allow,deny
  Allow from all
</Directory>" > /etc/httpd/conf.d/automock.conf
}
init ()
{
  # Clean
  rm -rf "${REPODIR}"/
  # Create repodirs
  mkdir -m 770 "${REPODIR}"/
  mkdir -m 770 "${REPODIR}"/packages/
  mkdir -m 770 "${REPODIR}"/packages/f{18,19}/
  # Create jobs directories
  mkdir -m 770 "${JOBS}"/ "${JOBS}"/pending/ "${TMPJOBSRUN}"/
  # Chown
  chown -R ${USER}:${GROUP} "${REPODIR}"/
}
if [[ `whoami` = root ]]; then
  if [[ "${1}" = install ]]; then
    # Install requirements
    yum install -y mock-scm sudo createrepo sed gawk httpd php
    # Make primary dir
    mkdir -m 770 "${DIR}"/
    cp -pR * "${DIR}"/
    chown -R apache:apache "${DIR}"/
    mkdir -m 750 "${DIR}"/backups/
    # Create user for build
    useradd -M -g ${GROUP} -G mock -s /bin/false ${USER}
    sudoers
    httpd
    init
    crontab -u apache cron
    systemctl enable httpd.service
    systemctl restart httpd.service
  elif [[ "$1" = uninstall ]]; then
    mv "${DIR}"/backups/welcome.conf /etc/httpd/conf.d/
    mv "${DIR}"/backups/sudoers /etc/
    rm -f /etc/httpd/conf.d/automock.conf
    crontab -u apache -r
    userdel -r ${USER}
    rm -rf "${ROOT}"/build/
    rm -rf "${DIR}"/
    rm -rf "${TMPJOBSRUN}"/
  fi
  exit 0
else
  echo "Failed! Run as root!"
  exit 1
fi
