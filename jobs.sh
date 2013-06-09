#!/bin/bash
# Jobs dir
JOBS="/home/repos/automock/build/jobs"
# Max tasks in the moment
MAXTASKS=1
if [[ `ls "${JOBS}"/running/*.task | wc -l` -lt ${MAXTASKS} ]]; then
  NEWTASK=`ls -c "${JOBS}"/pending/*.task | head -n1`
  #NEWTASK=`readlink -f "${NEWTASK}"`
  mv `readlink -f "${JOBS}"/pending/"${NEWTASK}"` "${JOBS}"/running/
  automock.sh "`cat "${JOBS}"/running/"${NEWTASK}"`"
fi

