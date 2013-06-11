#!/bin/bash
source /opt/automock/automock.conf
set -x
# Hack for daemonize
PATH="${PATH}:/usr/sbin"
verifydir ()
{
  if [[ ! -d "${1}"/ ]]; then
    mkdir -m 770 -p "${1}"/
  fi
}
if [[ ${MAINARCH} = x86_64 ]]; then
  verifydir "${TMPJOBSRUN}"
  verifydir "${JOBS}"
  verifydir "${JOBS}"/pending
  if [[ `find "${TMPJOBSRUN}" -type f -name "*.task" | wc -l` -lt ${MAXTASKS} ]]; then
    NEWTASK=`ls -tr "${JOBS}"/pending/*.task | head -n1`
    if [[ -z "${NEWTASK}" ]]; then
      exit 0
    fi
    # Move task in running
    cp "${NEWTASK}" "${TMPJOBSRUN}"/
    # Start build task in background^W
    daemonize "${DIR}"/wrapper.sh
  fi
  exit 0
else
  echo "For build need x86_64 OS !"
  exit 1
fi
