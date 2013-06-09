#!/bin/bash
source automock.conf
if [[ ${MAINARCH} = x86_64 ]]; then
  if [[ `ls "${JOBS}"/running/*.task | wc -l` -lt ${MAXTASKS} ]]; then
    NEWTASK=`ls -t "${JOBS}"/pending/*.task | head -n1`
    # Move task in running
    mv "${NEWTASK}" "${JOBS}"/running/
    # Start build task
    ./automock.sh "`cat "${JOBS}"/running/*.task`"
    # Delete complete task
    rm -f	"${JOBS}"/running/*.task
    # Start script again (monitoring)
    `readlink -f $0`
  fi
  exit 0
else
  echo "For build need x86_64 OS !"
  exit 1
fi
