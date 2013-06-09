#!/bin/bash
USER="automock"
useradd -G nginx,mock -s /bin/bash ${USER}
mkdir /home/${USER}/.ssh/
touch /home/${USER}/.ssh/authorized_keys
chown -R ${USER}:${USER} /home/build/.ssh/
chmod 700 /home/${USER}/.ssh/
chmod 600 /home/${USER}/.ssh/authorized_keys

