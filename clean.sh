#!/bin/bash
source /home/repos/automock/automock.conf
# Clean
sudo rm -rf "${REPODIR}"/*
# Create repodirs
mkdir -p "${REPODIR}"/packages/f{18,19}/
# Create jobs directories
mkdir -p "${JOBS}"/ "${JOBS}"/running/ "${TMPJOBSRUN}"/
