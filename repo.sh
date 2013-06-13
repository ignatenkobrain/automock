#!/bin/bash
source /opt/automock/automock.conf
for REPOSITORY in "$@"
do
  createrepo --update ${REPOSITORY}
done
