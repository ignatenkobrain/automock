#!/bin/bash
# Use as root
# ./nginx_selinux.sh /path/to/folder
SELINUXSTATUS=`sestatus | grep "SELinux status" | awk '{print($3)}'`
SELINUXHOMEDIRSSTATUS=`getsebool httpd_enable_homedirs | awk '{print($3)}'`
if [[ $SELINUXSTATUS = enabled ]]; then
	if [[ $1 = /home* && $SELINUXHOMEDIRSSTATUS = off ]]; then
		sudo setsebool -P httpd_enable_homedirs 1
	fi
	sudo semanage fcontext -a -t public_content_t "$1(/.*)?"
	sudo restorecon -F -R -v $1
fi
