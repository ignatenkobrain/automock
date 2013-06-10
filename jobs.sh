#!/bin/bash
source /home/repos/automock/automock.conf
verifydir ()
{
  if [[ ! -d "${1}"/ ]]; then
    mkdir -p "${1}"/
  fi
}

if [[ ${MAINARCH} = x86_64 ]]; then
  verifydir "${TMPJOBSRUN}"
  verifydir "${JOBS}"
  verifydir "${JOBS}"/pending
  if [[ `ls "${TMPJOBSRUN}"/*.task | wc -l` -lt ${MAXTASKS} ]]; then
    NEWTASK=`ls -t "${JOBS}"/pending/*.task | head -n1`
    if [[ -z "${NEWTASK}" ]]; then
      exit 0
    fi
    # Move task in running
    mv "${NEWTASK}" "${TMPJOBSRUN}"/
    # Start build task in background
    setsid "${AUTOMOCK}"/automock.sh "`cat "${TMPJOBSRUN}"/*.task`" &
  fi
  exit 0
else
  echo "For build need x86_64 OS !"
  exit 1
fi
