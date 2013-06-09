#!/bin/bash
source automock.conf
if [[ `whoami` = root ]]; then
  useradd -G nginx,mock -s /bin/bash ${USER}
  mkdir /home/${USER}/.ssh/
  cp ./authorized_keys /home/${USER}/.ssh/
  chown -R ${USER}:${USER} /home/${USER}/.ssh/
  chmod 700 /home/${USER}/.ssh/
  chmod 600 /home/${USER}/.ssh/authorized_keys
  exit 0
else
  echo "Failed! Run as root!"
  exit 1
fi
