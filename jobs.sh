#!/bin/bash
source automock.conf
if [[ ${MAINARCH} = x86_64 ]]; then
  if [[ `ls "${TMPJOBSRUN}"/*.task | wc -l` -lt ${MAXTASKS} ]]; then
    NEWTASK=`ls -t "${JOBS}"/pending/*.task | head -n1`
    # Move task in running
    mv "${NEWTASK}" "${TMPJOBSRUN}"/
    # Start build task
    nohup setsid ./automock.sh "`cat "${TMPJOBSRUN}"/*.task`"
  fi
  exit 0
else
  echo "For build need x86_64 OS !"
  exit 1
fi
