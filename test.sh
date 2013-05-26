#!/bin/sh
case "${SSH_ORIGINAL_COMMAND}" in
  automock.sh*)
    /home/repos/automock/${SSH_ORIGINAL_COMMAND}
    ;;
  *)
    echo "Not priveleged!"
    exit 1
    ;;
esac
