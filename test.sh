#!/bin/sh
case "${SSH_ORIGINAL_COMMAND}" in
  "/home/repos/automock/automock.sh *")
    ${SSH_ORIGINAL_COMMAND}
    ;;
  *)
    echo "Not priveleged!"
    exit 1
    ;;
esac
