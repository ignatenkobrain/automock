#!/bin/bash
source automock.conf
# Clean
sudo rm -rf "${REPODIR}"/*
# Create repodirs
mkdir -p "${REPODIR}"/f{18,19}/
# Create jobs
mkdir -p "${JOBS}" "${JOBS}"/running/ "${JOBS}"/pending/
