#!/bin/bash
if [[ `whoami` = root ]]; then
  USER="automock"
  useradd -G nginx,mock -s /bin/bash ${USER}
  mkdir /home/${USER}/.ssh/
  touch /home/${USER}/.ssh/authorized_keys
  chown -R ${USER}:${USER} /home/${USER}/.ssh/
  chmod 700 /home/${USER}/.ssh/
  chmod 600 /home/${USER}/.ssh/authorized_keys
  exit 0
else
  echo "Failed! Run as root!"
  exit 1
fi
