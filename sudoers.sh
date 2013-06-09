#!/bin/bash
if [[ `whoami` = root ]]; then
  USER="automock"
  cp /etc/sudoers /home/${USER}/sudoers
  echo "Defaults:automock !requiretty" >> /etc/sudoers
  echo "automock ALL=(ALL) NOPASSWD: /usr/sbin/semanage, /usr/sbin/restorecon, /usr/sbin/setsebool, /usr/bin/rm, /usr/bin/chown" >> /etc/sudoers
  exit 0
else
  echo "Failed! Run as root!"
  exit 1
fi
