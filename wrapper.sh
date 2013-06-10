#!/bin/bash
source /opt/automock/automock.conf
setsid sudo -u ${USER} "${DIR}"/automock.sh "`readlink -f "${TMPJOBSRUN}"/*.task`"
#"${DIR}"/jobs.sh
