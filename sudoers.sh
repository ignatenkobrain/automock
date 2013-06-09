#!/bin/bash
if [[ `whoami` = root ]]; then
  cp /etc/sudoers /etc/sudoers.automock
  echo "Defaults:automock !requiretty"; \
  echo "automock ALL=(ALL) NOPASSWD: /usr/sbin/semanage, /usr/sbin/restorecon, /usr/sbin/setsebool, /usr/bin/rm, /usr/bin/chown" >> /etc/sudoers
  exit 0
else
  echo "Failed! Run as root!"
  exit 1
fi
