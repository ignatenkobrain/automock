#!/bin/sh
case "${SSH_ORIGINAL_COMMAND}" in
  automock.sh*)
    # Add to path /usr/sbin for selinux
    export PATH="${PATH}:/usr/sbin"
    # Start automock in background with inhibition
    /home/repos/automock/${SSH_ORIGINAL_COMMAND} >/dev/null 2>&1 &
    # Let off from terminal
    disown -ar
    exit 0
    ;;
  *)
    echo "Not priveleged!"
    echo "Use automock.sh"
    exit 1
    ;;
esac
