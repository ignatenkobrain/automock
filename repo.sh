#!/bin/bash
source /opt/automock.conf
for REPOSITORY in "$@"
do
  createrepo --update ${REPOSITORY}
done
