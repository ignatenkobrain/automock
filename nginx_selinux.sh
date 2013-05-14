#!/bin/bash
#Use as root:
#./nginx_selinux.sh /path/to/folder
SELINUXSTATUS=`sestatus | grep "SELinux status" | awk '{print($3)}'`
SELINUXHOMEDIRSSTATUS=`getsebool httpd_enable_homedirs | awk '{print($3)}'`
if [[ $1 = /home* && $SELINUXHOMEDIRSSTATUS = off && $SELINUXSTATUS = enabled ]]; then
  setsebool -P httpd_enable_homedirs 1
fi
semanage fcontext -a -t public_content_t "$1(/.*)?"
restorecon -F -R -v $1
