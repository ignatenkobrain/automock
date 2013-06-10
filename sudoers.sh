#!/bin/bash
source automock.conf
if [[ `whoami` = root ]]; then
  cp /etc/sudoers /home/${USER}/sudoers
  echo "Defaults:automock !requiretty" >> /etc/sudoers
  echo "${USER} ALL=(${USER}) NOPASSWD: /usr/sbin/semanage, /usr/sbin/restorecon, /usr/sbin/setsebool, /usr/bin/rm, /usr/bin/chown" >> /etc/sudoers
  echo "apache ALL=(${USER}) NOPASSWD: ${AUTOMOCK}/automock.sh" >> /etc/sudoers
  exit 0
else
  echo "Failed! Run as root!"
  exit 1
fi
